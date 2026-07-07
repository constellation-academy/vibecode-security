#!/usr/bin/env bash
set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

REPO_PATH="${1:-.}"
CRITICAL=0
HIGH=0
MEDIUM=0
LOW=0

critical() { echo -e "  ${RED}[CRITICAL]${NC} $1"; CRITICAL=$((CRITICAL+1)); }
high()     { echo -e "  ${RED}[HIGH]    ${NC} $1"; HIGH=$((HIGH+1)); }
medium()   { echo -e "  ${YELLOW}[MEDIUM]  ${NC} $1"; MEDIUM=$((MEDIUM+1)); }
low()      { echo -e "  ${YELLOW}[LOW]     ${NC} $1"; LOW=$((LOW+1)); }
pass()     { echo -e "  ${GREEN}[PASS]    ${NC} $1"; }
section()  { echo -e "\n${BLUE}━━ $1 ━━${NC}"; }

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Vibecode Security Scan             ║"
echo "╚══════════════════════════════════════╝"
echo "Repo: $REPO_PATH"
echo ""

# ── 1. SECRETS ────────────────────────────────────────────────────────────────
section "Secrets"

# Anthropic API keys
HITS=$(grep -rn --include="*.py" --include="*.js" --include="*.ts" --include="*.tsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include=".env*" \
  -E "(sk-ant-|sk-proj-)[a-zA-Z0-9\-]{20,}" "$REPO_PATH" 2>/dev/null \
  | grep -v "\.env\.example" | grep -v "\.env\.local\.example" || true)
if [ -n "$HITS" ]; then
  echo "$HITS"
  critical "Anthropic API key hardcoded in source"
  echo "  Fix prompt: \"Move the hardcoded Anthropic API key in [file] to an env var called ANTHROPIC_API_KEY. Add .env to .gitignore and create a .env.example with placeholder value.\""
else
  pass "No hardcoded Anthropic keys"
fi

# OpenAI API keys
HITS=$(grep -rn --include="*.py" --include="*.js" --include="*.ts" --include="*.tsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include=".env*" \
  -E 'sk-[a-zA-Z0-9]{20,}' "$REPO_PATH" 2>/dev/null \
  | grep -v "\.env\.example" | grep -v "\.env\.local\.example" || true)
if [ -n "$HITS" ]; then
  echo "$HITS"
  critical "OpenAI API key hardcoded in source"
  echo "  Fix prompt: \"Move the hardcoded OpenAI API key in [file] to OPENAI_API_KEY env var.\""
else
  pass "No hardcoded OpenAI keys"
fi

# Supabase anon keys (start with eyJ — base64 JWT)
HITS=$(grep -rn --include="*.py" --include="*.js" --include="*.ts" --include="*.tsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include=".env*" \
  -E '"?eyJ[a-zA-Z0-9+/=]{50,}"?' "$REPO_PATH" 2>/dev/null \
  | grep -v "\.env\.example" | grep -v "\.env\.local\.example" || true)
if [ -n "$HITS" ]; then
  echo "$HITS"
  critical "Supabase anon key hardcoded in source (publicly visible to all users)"
  echo "  Fix prompt: \"Move the hardcoded Supabase anon key in [file] to SUPABASE_ANON_KEY env var.\""
else
  pass "No hardcoded Supabase JWT keys"
fi

# Supabase URL hardcoded as string literal (not via env)
HITS=$(grep -rn --include="*.py" --include="*.js" --include="*.ts" --include="*.tsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include=".env*" \
  -E "SUPABASE_URL\s*=\s*[\"']?https://" "$REPO_PATH" 2>/dev/null \
  | grep -v "\.env\.example" | grep -v "\.env\.local\.example" || true)
if [ -n "$HITS" ]; then
  echo "$HITS"
  critical "Supabase URL hardcoded in source (leaks database identity)"
  echo "  Fix prompt: \"Move the hardcoded Supabase URL in [file] to SUPABASE_URL env var.\""
else
  pass "No hardcoded Supabase URLs"
fi

# Generic secret patterns: api_key = "...", password = "..."
HITS=$(grep -rn --include="*.py" --include="*.js" --include="*.ts" --include="*.tsx" \
  --include="*.json" --include="*.yaml" --include="*.yml" --include="*.toml" --include=".env*" \
  -E "(api_key|apikey|api_secret|client_secret|password|access_token)\s*[=:]\s*[\"']?[^\"'\s]{8,}[\"']?" \
  "$REPO_PATH" 2>/dev/null \
  | grep -iv "example\|placeholder\|your_\|<\|TODO\|test\|fake\|dummy" || true)
if [ -n "$HITS" ]; then
  echo "$HITS"
  high "Possible hardcoded credential — review these lines"
  echo "  Fix prompt: \"Move any hardcoded credentials in [file] to environment variables.\""
else
  pass "No obvious generic hardcoded credentials"
fi

# ── 2. DATA FILES IN REPO ─────────────────────────────────────────────────────
section "Data Files in Repo"

DATA_HITS=$(git -C "$REPO_PATH" ls-files 2>/dev/null \
  | grep -E "\.(xlsx|csv|pdf|zip)$" \
  | grep -iv "template\|example\|sample\|schema\|demo" || true)
if [ -n "$DATA_HITS" ]; then
  echo "$DATA_HITS" | while read -r f; do echo "  $f"; done
  critical "Real data files committed to git — these may contain personal data (DSGVO risk)"
  echo "  Fix prompt: \"Remove [files] from git history: git rm --cached [file] and add to .gitignore. If the file contains real personal data, also run: git filter-branch or BFG Repo Cleaner to purge from history.\""
else
  pass "No data files committed"
fi

# Sensitive filenames
NAME_HITS=$(git -C "$REPO_PATH" ls-files 2>/dev/null \
  | grep -iE "(stammdaten|kundendaten|mitarbeiter|export|backup|kunde|personal)" || true)
if [ -n "$NAME_HITS" ]; then
  echo "$NAME_HITS" | while read -r f; do echo "  $f"; done
  high "Files with sensitive-sounding names in repo — verify they contain no personal data"
else
  pass "No sensitive-named files detected"
fi

# ── 3. ENVIRONMENT DISCIPLINE ─────────────────────────────────────────────────
section "Environment Discipline"

# .env actually committed
if git -C "$REPO_PATH" ls-files 2>/dev/null | grep -qE "^\.env(\..+)?$"; then
  critical ".env or .env.local/.env.production committed to git — secrets are now in version history"
  echo "  Fix prompt: \"Remove committed env files: git rm --cached .env .env.local .env.production 2>/dev/null; echo '.env*' >> .gitignore && git commit -m 'fix: remove .env files from tracking'\""
else
  pass ".env not committed"
fi

# .gitignore exists
if [ ! -f "$REPO_PATH/.gitignore" ]; then
  medium "No .gitignore file found"
  echo "  Fix prompt: \"Create a .gitignore file that includes: .env, .env.local, *.xlsx, *.csv, node_modules/, __pycache__/, .DS_Store\""
else
  if ! grep -q "^\.env" "$REPO_PATH/.gitignore" 2>/dev/null; then
    medium ".gitignore exists but .env is not listed — future .env files could be committed accidentally"
    echo "  Fix prompt: \"Add '.env' and '.env.local' to .gitignore\""
  else
    pass ".gitignore covers .env"
  fi
fi

# ── 4. DEPENDENCY AUDIT ───────────────────────────────────────────────────────
section "Dependency Audit"

HAS_NPM=false
HAS_PIP=false

if find "$REPO_PATH" -maxdepth 2 -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | grep -q .; then
  HAS_NPM=true
fi

if find "$REPO_PATH" -maxdepth 2 -name "requirements.txt" 2>/dev/null | grep -q .; then
  HAS_PIP=true
fi

if [ "$HAS_NPM" = true ]; then
  PKG_DIR=$(find "$REPO_PATH" -maxdepth 2 -name "package.json" -not -path "*/node_modules/*" 2>/dev/null | head -1 | xargs dirname)
  echo "  Running npm audit in $PKG_DIR ..."
  if command -v npm &>/dev/null; then
    AUDIT_OUT=$(cd "$PKG_DIR" && npm audit --audit-level=moderate --json 2>/dev/null || true)
    CRITICAL_COUNT=$(echo "$AUDIT_OUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('metadata',{}).get('vulnerabilities',{}).get('critical',0))" 2>/dev/null || echo 0)
    HIGH_COUNT=$(echo "$AUDIT_OUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('metadata',{}).get('vulnerabilities',{}).get('high',0))" 2>/dev/null || echo 0)
    if [ "$CRITICAL_COUNT" -gt 0 ]; then
      critical "npm audit: $CRITICAL_COUNT critical vulnerabilities in dependencies"
      echo "  Fix prompt: \"Run 'npm audit fix' to auto-fix dependency vulnerabilities. For unfixable ones, replace the package with a maintained alternative.\""
    elif [ "$HIGH_COUNT" -gt 0 ]; then
      high "npm audit: $HIGH_COUNT high severity vulnerabilities in dependencies"
      echo "  Fix prompt: \"Run 'npm audit fix' — if that doesn't resolve everything, check 'npm audit' for which packages to update manually.\""
    else
      pass "npm audit: no critical or high vulnerabilities"
    fi
  else
    low "npm not found — skipping JS dependency audit. Install Node.js to enable this check."
  fi
fi

if [ "$HAS_PIP" = true ]; then
  REQ_FILE=$(find "$REPO_PATH" -maxdepth 2 -name "requirements.txt" 2>/dev/null | head -1)
  echo "  Running pip-audit on $REQ_FILE ..."
  if command -v pip-audit &>/dev/null; then
    PIPAUDIT_OUT=$(pip-audit -r "$REQ_FILE" --format json 2>/dev/null || true)
    VULN_COUNT=$(echo "$PIPAUDIT_OUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    total = sum(len(dep.get('vulns',[])) for dep in d.get('dependencies',[]))
    print(total)
except:
    print(0)
" 2>/dev/null || echo 0)
    if [ "$VULN_COUNT" -gt 0 ]; then
      high "pip-audit: $VULN_COUNT vulnerable Python package(s)"
      echo "$PIPAUDIT_OUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    for dep in d.get('dependencies', []):
        for vuln in dep.get('vulns', []):
            print(f\"    {dep['name']} {dep['version']}: {vuln['id']}\")
except:
    pass
" 2>/dev/null || true
      echo "  Fix prompt: \"Update the vulnerable packages in requirements.txt to the fixed versions shown in the pip-audit output.\""
    else
      pass "pip-audit: no known vulnerabilities"
    fi
  else
    low "pip-audit not installed — run 'pip install pip-audit' to enable Python dependency scanning."
  fi
fi

if [ "$HAS_NPM" = false ] && [ "$HAS_PIP" = false ]; then
  low "No package.json or requirements.txt found — dependency audit skipped"
fi

# ── 5. AUTHENTICATION ─────────────────────────────────────────────────────────
section "Authentication"

AUTH_FOUND=false

# Next.js / React auth libraries — check package.json deps
if find "$REPO_PATH" -maxdepth 2 -name "package.json" -not -path "*/node_modules/*" 2>/dev/null \
  | xargs grep -l '"next-auth"\|"@clerk/\|"@auth0/\|"@supabase/auth-helpers\|"firebase/auth\|"lucia"' 2>/dev/null \
  | grep -q .; then
  pass "JS auth library detected (next-auth / clerk / auth0 / supabase-auth)"
  AUTH_FOUND=true
fi

# Python auth libraries — check requirements.txt
if find "$REPO_PATH" -maxdepth 2 -name "requirements.txt" 2>/dev/null \
  | xargs grep -l "streamlit-authenticator\|flask-login\|fastapi-users\|authlib\|python-jose" 2>/dev/null \
  | grep -q .; then
  pass "Python auth library detected"
  AUTH_FOUND=true
fi

# Netlify Identity (only in app source files, not shell scripts)
if grep -rq --include="*.js" --include="*.ts" --include="*.tsx" --include="*.html" \
  "netlify-identity\|GoTrueClient\|netlifyIdentity" "$REPO_PATH" 2>/dev/null; then
  pass "Netlify Identity detected"
  AUTH_FOUND=true
fi

# Supabase auth usage (not just DB client)
if grep -rqE "supabase\.auth\.(signIn|signUp|getUser|getSession)" "$REPO_PATH" \
  --include="*.js" --include="*.ts" --include="*.tsx" --include="*.py" 2>/dev/null; then
  pass "Supabase Auth usage detected"
  AUTH_FOUND=true
fi

# Plain HTML with no backend framework — flag immediately
HTML_ONLY=true
for ext in py js ts tsx; do
  if find "$REPO_PATH" -name "*.$ext" -not -path "*/.git/*" -not -path "*/node_modules/*" 2>/dev/null | grep -q .; then
    HTML_ONLY=false
    break
  fi
done

if [ "$HTML_ONLY" = true ]; then
  if find "$REPO_PATH" -name "*.html" 2>/dev/null | grep -q .; then
    critical "Plain HTML app with no backend — authentication cannot be server-enforced. Use Netlify Identity or Cloudflare Access."
    AUTH_FOUND=true  # set to true to avoid double-reporting below
  else
    # No source files and no HTML — this is not a web app (e.g. a dev tool or library)
    pass "No web app detected — authentication check skipped"
    AUTH_FOUND=true
  fi
fi

if [ "$AUTH_FOUND" = false ]; then
  critical "No authentication library detected — every user can access the app without logging in"
  echo "  Fix prompt: \"Add authentication to this app so every route/page requires a logged-in user."
  echo "  For Next.js: use next-auth. For Python/Streamlit: use streamlit-authenticator."
  echo "  For Netlify: use Netlify Identity. Unauthenticated requests must return 401.\""
fi

# ── 6. EXPOSED ROUTES & CONFIG ────────────────────────────────────────────────
section "Exposed Routes & Config"

# Admin/debug routes without visible auth guard
ROUTE_HITS=$(grep -rn --include="*.py" --include="*.js" --include="*.ts" \
  -E "(route|app\.(get|post|all)|path)\s*[\(=]\s*[\"']/?(admin|debug|swagger|graphql|internal|_debug)" \
  "$REPO_PATH" 2>/dev/null \
  | grep -iv "auth\|require\|protect\|middleware\|login" || true)
if [ -n "$ROUTE_HITS" ]; then
  echo "$ROUTE_HITS"
  high "Admin/debug route detected — verify it requires authentication"
  echo "  Fix prompt: \"Add authentication middleware to the /admin and /debug routes so only authenticated admins can access them. Unauthenticated requests must return 404 or 401.\""
else
  pass "No obvious unprotected admin/debug routes"
fi

# NODE_ENV not set to production in deploy config (only check if a deploy config exists)
HAS_DEPLOY_CONFIG=false
for config_file in netlify.toml vercel.json; do
  if [ -f "$REPO_PATH/$config_file" ]; then
    HAS_DEPLOY_CONFIG=true
    break
  fi
done
if [ "$HAS_DEPLOY_CONFIG" = true ]; then
  PROD_SET=false
  for config_file in netlify.toml vercel.json .env.production next.config.js; do
    if [ -f "$REPO_PATH/$config_file" ] && grep -q "production\|NODE_ENV" "$REPO_PATH/$config_file" 2>/dev/null; then
      PROD_SET=true
      break
    fi
  done
  if [ "$PROD_SET" = false ]; then
    medium "NODE_ENV=production not found in deploy config — app may run in dev mode with verbose errors"
    echo "  Fix prompt: \"Set NODE_ENV=production in your deploy config (netlify.toml [build] environment or platform dashboard env vars).\""
  else
    pass "Production config detected"
  fi
fi

# HTTPS redirect in netlify.toml
if [ -f "$REPO_PATH/netlify.toml" ]; then
  if ! grep -qE "https|http_to_https|force\s*=\s*true" "$REPO_PATH/netlify.toml" 2>/dev/null; then
    medium "netlify.toml found but no HTTPS redirect rule — traffic may arrive over plain HTTP"
    echo "  Fix prompt: \"Add HTTPS redirect to netlify.toml: [[redirects]] from = 'http://*' to = 'https://:splat' status = 301 force = true\""
  else
    pass "HTTPS config present in netlify.toml"
  fi
fi

# ── 7. SUMMARY ────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   Scan Complete                      ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo -e "  ${RED}Critical: $CRITICAL${NC}   ${RED}High: $HIGH${NC}   ${YELLOW}Medium: $MEDIUM${NC}   ${YELLOW}Low: $LOW${NC}"
echo ""

TOTAL_BLOCKERS=$((CRITICAL + HIGH))
if [ "$TOTAL_BLOCKERS" -gt 0 ]; then
  echo -e "  ${RED}✗ NOT READY — fix $TOTAL_BLOCKERS critical/high finding(s) above then re-run${NC}"
  echo ""
  echo "  Vibecode each fix using the prompts above, then run:"
  echo "    bash scan.sh $REPO_PATH"
  exit 1
elif [ "$MEDIUM" -gt 0 ]; then
  echo -e "  ${YELLOW}⚠ CONDITIONAL — no blockers, but $MEDIUM medium finding(s) to review${NC}"
  echo "  Ask your tech reviewer to check the medium findings before going live."
  exit 0
else
  echo -e "  ${GREEN}✓ SCAN PASSED — ready for tech review${NC}"
  echo "  Next: Ask a tech reviewer to run the 'vibecode-security' Claude skill in reviewer mode."
  exit 0
fi
