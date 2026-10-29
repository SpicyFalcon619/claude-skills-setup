<#
.SYNOPSIS
  claude-skills-setup: installs the global Claude Code design, engineering and browser toolkit.
.DESCRIPTION
  Needs Node 22+, npm, git, the `claude` CLI, and Chrome/Edge/Chromium.
  Safe to re-run: it updates what is installed. Re-running turns Superpowers back off globally
  (it is meant to be enabled per project).
.EXAMPLE
  ./install.ps1
#>

$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$total = 9
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
function TryRun([scriptblock]$cmd) {
  & $cmd
  if ($LASTEXITCODE -ne 0) { Write-Warning "Did not succeed (it may already be installed): $cmd" }
}
function EnsureUv {
  if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Write-Host 'Installing uv (https://astral.sh/uv)...'
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    $env:Path = "$HOME\.local\bin;$env:Path"
  }
}

# Preflight
foreach ($tool in 'node', 'npm', 'git', 'claude') {
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

Step 'Anthropic skills (the ones not bundled with Claude already)'
Run { npx -y skills add https://github.com/anthropics/skills --skill algorithmic-art brand-guidelines canvas-design doc-coauthoring internal-comms slack-gif-creator theme-factory -g -a claude-code -y }

Step 'Engineering plugins: Matt Pocock Skills, Karpathy Skills, Superpowers (off by default)'
TryRun { claude plugin marketplace update claude-plugins-official }
TryRun { claude plugin install mattpocock-skills@claude-plugins-official --scope user }
TryRun { claude plugin marketplace add multica-ai/andrej-karpathy-skills }
TryRun { claude plugin install andrej-karpathy-skills@karpathy-skills --scope user }
TryRun { claude plugin install superpowers@claude-plugins-official --scope user }
# Superpowers is meant for real projects only: disabled globally, enabled per project.
Run { claude plugin disable superpowers@claude-plugins-official --scope user }

Step 'Graphify (knowledge graph of a codebase)'
EnsureUv
Run { uv tool install --force graphifyy }
Run { graphify install --platform windows }

Step 'Project kickoff skill (reminds you to enable Superpowers on real projects)'
$kick = Join-Path $HOME '.claude/skills/project-kickoff'
New-Item -ItemType Directory -Force $kick | Out-Null
Copy-Item (Join-Path $here 'project-kickoff/SKILL.md') (Join-Path $kick 'SKILL.md') -Force

Write-Host ""
Write-Host 'Done. Installed skills:' -ForegroundColor Green
Get-ChildItem (Join-Path $HOME '.claude/skills') | ForEach-Object { "  $($_.Name)" }
Write-Host ""
Write-Host 'Plugins:'
claude plugin list
Write-Host ""
Write-Host 'Next: restart Claude Code, then run /impeccable init inside a project.'
