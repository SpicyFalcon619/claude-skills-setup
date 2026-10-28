---
name: project-kickoff
description: >-
  Reminds the user to turn on the Superpowers plugin when they start a real project, because
  Superpowers is installed but disabled by default. Use when the user is beginning substantial new
  work: a new app, product, service, library or repo, scaffolding a project, or a multi-step feature
  that needs planning. Do not use for quick questions, one-off scripts, small edits, config or
  tooling work, or anything that is not a real project.
---

# Project kickoff

Superpowers (a plan, test and debug workflow) is installed globally but **disabled by default**, so it
does not add its process to quick tasks. It is switched on per project.

## When this applies

A real project: starting a new app, product, service or library; scaffolding a repo; or a feature large
enough to need a plan. It does not apply to questions, one-off scripts, small fixes, or setup of the
user's own tools.

## What to do

1. Check whether it is already on for this project: `claude plugin list` and look at the
   `superpowers@claude-plugins-official` status. If it is enabled, say nothing and continue.
2. If it is disabled, ask once, in one or two short sentences, whether to turn Superpowers on for this
   project. Say what it changes: work will follow brainstorm, plan, test-first, verify. Do not enable
   it without a yes. If the user declines, drop it and do not ask again in this project.
3. On yes, run from the project root:

   ```bash
   claude plugin enable superpowers@claude-plugins-official --scope project
   ```

   This writes `enabledPlugins` into the project's `.claude/settings.json`, which can be committed to
   share it. Use `--scope local` instead to keep it private to this machine. Tell the user to restart
   or reload Claude Code so the plugin loads, because plugins do not hot-load into a running session.
4. Mention at most once, only where relevant:
   - a project with a user interface: run `/impeccable init` to capture design context;
   - an existing codebase of real size: `/graphify .` builds a queryable map of it.

## Turning it off again

`claude plugin disable superpowers@claude-plugins-official --scope project` (or edit
`.claude/settings.json`).
