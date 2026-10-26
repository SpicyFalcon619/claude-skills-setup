#!/usr/bin/env bash
# Installs the global Claude Code design toolkit. Needs Node 22+, git, and Chrome/Edge/Chromium.
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd ~

npx -y skills add https://github.com/Leonxlnx/taste-skill --skill design-taste-frontend -g -a claude-code -y
npx -y skills add https://github.com/vercel-labs/agent-skills --skill web-design-guidelines -g -a claude-code -y
npm install -g @playwright/cli@latest
playwright-cli install --skills
npx -y impeccable install --providers=claude --scope=global

mkdir -p ~/design-references
if [ -d ~/design-references/awesome-design-md/.git ]; then
  git -C ~/design-references/awesome-design-md pull
else
  git clone --depth 1 https://github.com/VoltAgent/awesome-design-md.git ~/design-references/awesome-design-md
fi
mkdir -p ~/.claude/skills/design-references
cp "$HERE/design-references/SKILL.md" ~/.claude/skills/design-references/SKILL.md

echo "Done. Restart Claude Code, then run /impeccable init inside a project."
