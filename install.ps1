# vibecode-security installer for Windows
$dest = "$env:USERPROFILE\.claude\skills\vibecode-security"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
$base = "https://raw.githubusercontent.com/constellation-academy/vibecode-security/main/skills/vibecode-security"
Invoke-WebRequest -Uri "$base/SKILL.md" -OutFile "$dest\SKILL.md" -UseBasicParsing
Write-Host "vibecode-security skill installed. Restart Claude Code, then say: security check"
