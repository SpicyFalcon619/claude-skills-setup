<#
.SYNOPSIS
  claude-skills-setup: installs the global Claude Code design and browser toolkit.
.DESCRIPTION
  Needs Node 22+, npm, git, and Chrome/Edge/Chromium. Safe to re-run: it updates what is installed.
.PARAMETER WithAgentReach
  Also installs Agent Reach (opt-in). Read the Security section of the README first.
.EXAMPLE
  ./install.ps1
.EXAMPLE
  ./install.ps1 -WithAgentReach
#>
param([switch]$WithAgentReach)

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$total = if ($WithAgentReach) { 6 } else { 5 }
$script:step = 0

function Step([string]$title) {
  $script:step++
  Write-Host ""
  Write-Host ("[{0}/{1}] {2}" -f $script:step, $total, $title) -ForegroundColor Cyan
}
function Run([scriptblock]$cmd) {
  & $cmd
  if ($LASTEXITCODE -ne 0) { throw "Command failed (exit $LASTEXITCODE): $cmd" }
}

# Preflight
foreach ($tool in 'node', 'npm', 'git') {
  if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) { throw "$tool is required but was not found." }
}
$nodeMajor = [int](node -p "process.versions.node.split('.')[0]")
if ($nodeMajor -lt 22) { throw "Node 22+ required, found $(node -v)." }

Set-Location ~

Step 'Taste Skill v2 (design-taste-frontend)'
Run { npx -y skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend -g -a claude-code -y }

Step 'Web Design Guidelines'
Run { npx -y skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines -g -a claude-code -y }

Step 'Playwright CLI and its skill'
Run { npm install -g '@playwright/cli@latest' }
Run { playwright-cli install --skills }

Step 'Impeccable (skill, engine, agents and hooks)'
Run { npx -y impeccable install --providers=claude --scope=global }

Step 'Design references (84 brand design systems) and the wrapper skill'
$refs = Join-Path $HOME 'design-references'
New-Item -ItemType Directory -Force $refs | Out-Null
$repo = Join-Path $refs 'awesome-design-md'
if (Test-Path (Join-Path $repo '.git')) { Run { git -C $repo pull --ff-only } }
else { Run { git clone --depth 1 https://github.com/VoltAgent/awesome-design-md.git $repo } }
$dest = Join-Path $HOME '.claude/skills/design-references'
New-Item -ItemType Directory -Force $dest | Out-Null
Copy-Item (Join-Path $here 'design-references/SKILL.md') (Join-Path $dest 'SKILL.md') -Force

if ($WithAgentReach) {
  Step 'Agent Reach (OPT-IN: web, video and social reading)'
  if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing uv (https://astral.sh/uv)...'
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:Path = "$HOME\.local\bin;$env:Path"
  }
  Run { uv tool install --force https://github.com/Panniantong/Agent-Reach/releases/latest/download/agent-reach.zip }
  Run { agent-reach setup }
}

Write-Host ""
Write-Host 'Done. Installed skills:' -ForegroundColor Green
Get-ChildItem (Join-Path $HOME '.claude/skills') | ForEach-Object { "  $($_.Name)" }
Write-Host ""
Write-Host 'Next: restart Claude Code, then run /impeccable init inside a project.'
