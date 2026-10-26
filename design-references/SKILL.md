---
name: design-references
description: >-
  Look up a real brand's design system (colours, type, spacing, components) from a local copy of
  VoltAgent/awesome-design-md. Use when the user asks to make a UI "look like", "in the style of" or
  "inspired by" a known product or brand (Stripe, Linear, Vercel, Notion, Apple, Airbnb, Spotify, etc.),
  or asks for a reference design system to start from.
---

# Design references

A local clone of https://github.com/VoltAgent/awesome-design-md lives at
`~/design-references/awesome-design-md/design-md/<brand>/` (the user's home folder). Each brand folder has a
`DESIGN.md` (palette, typography, component styles, layout principles, agent prompt guide) and an HTML
preview.

## How to use

1. List the folder names in `design-md/` and match the brand the user named. If there is no exact
   match, pick the closest one or two and say so.
2. Read that brand's `DESIGN.md` in full before writing any UI.
3. Build with its tokens (colours, type scale, radii, spacing) instead of inventing your own. Treat it
   as a reference for structure and restraint, and do not copy logos, wordmarks or proprietary copy.
4. If the user wants the system kept in their project, copy the `DESIGN.md` to the project root.

## Refresh

To update the library: `git -C ~/design-references/awesome-design-md pull`.

## Combining with other skills

For a distinctive, non-brand-derived look use `design-taste-frontend`. When both apply, take tokens
from the reference and composition and verification from `design-taste-frontend`. After building, run
`web-design-guidelines` for an accessibility and UX audit.
