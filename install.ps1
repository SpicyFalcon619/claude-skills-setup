# Installs the global Claude Code design toolkit. Needs Node 22+, git, and Chrome/Edge/Chromium.
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
Set-Location ~

npx -y skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend -g -a claude-code -y
npx -y skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines -g -a claude-code -y
npm install -g '@playwright/cli@latest'
playwright-cli install --skills
npx -y impeccable install --providers=claude --scope=global

$refs = Join-Path $HOME 'design-references'
New-Item -ItemType Directory -Force $refs | Out-Null
$repo = Join-Path $refs 'awesome-design-md'
if (Test-Path (Join-Path $repo '.git')) { git -C $repo pull }
else { git clone --depth 1 https://github.com/VoltAgent/awesome-design-md.git $repo }

$dest = Join-Path $HOME '.claude/skills/design-references'
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item (Join-Path $here 'design-references/SKILL.md') (Join-Path $dest 'SKILL.md') -Force

Write-Host 'Done. Restart Claude Code, then run /impeccable init inside a project.'
