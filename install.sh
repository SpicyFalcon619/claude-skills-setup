#!/usr/bin/env bash
# claude-skills-setup: installs the global Claude Code design and browser toolkit.
#
# Usage:  bash install.sh [--with-agent-reach]
#
# Needs Node 22+, npm, git, and Chrome/Edge/Chromium. Safe to re-run: it updates what is installed.
set -euo pipefail

WITH_AGENT_REACH=0
for arg in "$@"; do
  case "$arg" in
    --with-agent-reach) WITH_AGENT_REACH=1 ;;
    -h|--help) sed -n '2,7p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg" >&2; exit 2 ;;
  esac
done

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STEP=0
TOTAL=5
[ "$WITH_AGENT_REACH" -eq 1 ] && TOTAL=6

step() { STEP=$((STEP + 1)); printf '\n[%d/%d] %s\n' "$STEP" "$TOTAL" "$1"; }
die()  { printf 'error: %s\n' "$1" >&2; exit 1; }

# Preflight
command -v node >/dev/null 2>&1 || die "Node.js is required (22 or newer)."
command -v npm  >/dev/null 2>&1 || die "npm is required."
command -v git  >/dev/null 2>&1 || die "git is required."
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

if [ "$WITH_AGENT_REACH" -eq 1 ]; then
  step "Agent Reach (OPT-IN: web, video and social reading)"
  if ! command -v uv >/dev/null 2>&1; then
    echo "Installing uv (https://astral.sh/uv)..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi
  uv tool install --force https://github.com/Panniantong/Agent-Reach/releases/latest/download/agent-reach.zip
  agent-reach setup
fi

printf '\nDone. Installed skills:\n'
ls -1 ~/.claude/skills
printf '\nNext: restart Claude Code, then run /impeccable init inside a project.\n'
