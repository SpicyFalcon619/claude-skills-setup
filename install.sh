#!/usr/bin/env bash
# claude-skills-setup: installs the global Claude Code design, engineering and browser toolkit.
#
# Usage:  bash install.sh [--with-agent-reach]
#
# Needs Node 22+, npm, git, the `claude` CLI, and Chrome/Edge/Chromium.
# Safe to re-run: it updates what is installed. Note that re-running turns Superpowers
# back off globally (it is meant to be enabled per project).
set -euo pipefail

WITH_AGENT_REACH=0
for arg in "$@"; do
  case "$arg" in
    --with-agent-reach) WITH_AGENT_REACH=1 ;;
    -h|--help) sed -n '2,9p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP=0
TOTAL=9
[ "$WITH_AGENT_REACH" -eq 1 ] && TOTAL=10

step() { STEP=$((STEP + 1)); printf '\n[%d/%d] %s\n' "$STEP" "$TOTAL" "$1"; }
die()  { printf 'error: %s\n' "$1" >&2; exit 1; }
try()  { "$@" || printf 'warning: "%s" did not succeed (it may already be installed)\n' "$*"; }

ensure_uv() {
  if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv (https://astral.sh/uv)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
}

# Preflight
command -v node   >/dev/null 2>&1 || die "Node.js is required (22 or newer)."
command -v npm    >/dev/null 2>&1 || die "npm is required."
command -v git    >/dev/null 2>&1 || die "git is required."
command -v claude >/dev/null 2>&1 || die "the 'claude' CLI is required (it installs the plugins)."
NODE_MAJOR="$(node -p 'process.versions.node.split(".")[0]')"
[ "$NODE_MAJOR" -ge 22 ] || die "Node 22+ required, found $(node -v)."

cd ~

step "Taste Skill v2 (design-taste-frontend)"
npx -y skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend -g -a claude-code -y

step "Web Design Guidelines"
npx -y skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines -g -a claude-code -y

step "Playwright CLI and its skill"
npm install -g @playwright/cli@latest
playwright-cli install --skills

step "Impeccable (skill, engine, agents and hooks)"
npx -y impeccable install --providers=claude --scope=global

step "Design references (84 brand design systems) and the wrapper skill"
mkdir -p ~/design-references
if [ -d ~/design-references/awesome-design-md/.git ]; then
  git -C ~/design-references/awesome-design-md pull --ff-only
else
  git clone --depth 1 https://github.com/VoltAgent/awesome-design-md.git ~/design-references/awesome-design-md
fi
mkdir -p ~/.claude/skills/design-references
cp "$HERE/design-references/SKILL.md" ~/.claude/skills/design-references/SKILL.md

step "Anthropic skills (the ones not bundled with Claude already)"
npx -y skills add https://github.com/anthropics/skills \
  --skill algorithmic-art brand-guidelines canvas-design doc-coauthoring internal-comms slack-gif-creator theme-factory \
  -g -a claude-code -y

step "Engineering plugins: Matt Pocock Skills, Karpathy Skills, Superpowers (off by default)"
claude plugin marketplace update claude-plugins-official || true
try claude plugin install mattpocock-skills@claude-plugins-official --scope user
try claude plugin marketplace add multica-ai/andrej-karpathy-skills
try claude plugin install andrej-karpathy-skills@karpathy-skills --scope user
try claude plugin install superpowers@claude-plugins-official --scope user
# Superpowers is meant for real projects only: disabled globally, enabled per project.
claude plugin disable superpowers@claude-plugins-official --scope user

step "Graphify (knowledge graph of a codebase)"
ensure_uv
uv tool install --force graphifyy
graphify install --platform claude

step "Project kickoff skill (reminds you to enable Superpowers on real projects)"
mkdir -p ~/.claude/skills/project-kickoff
cp "$HERE/project-kickoff/SKILL.md" ~/.claude/skills/project-kickoff/SKILL.md

if [ "$WITH_AGENT_REACH" -eq 1 ]; then
  step "Agent Reach (OPT-IN: web, video and social reading)"
  ensure_uv
  uv tool install --force https://github.com/Panniantong/Agent-Reach/releases/latest/download/agent-reach.zip
  agent-reach setup
fi

printf '\nDone. Installed skills:\n'
ls -1 ~/.claude/skills
printf '\nPlugins:\n'
claude plugin list
printf '\nNext: restart Claude Code, then run /impeccable init inside a project.\n'
