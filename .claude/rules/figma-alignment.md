---
paths:
  - "app/views/**/*.erb"
  - "app/components/**/*.rb"
  - "app/assets/tailwind/**"
  - "app/helpers/**_helper.rb"
---

# Figma Design Alignment

## Before adding ANY UI work item to REMAINING-WORK.md or a plan
- **Check if the feature exists in Figma** before scheduling implementation
- If PRD/FA mentions a UI element but Figma doesn't show it, it falls into one of three categories:
  1. **Simple/predictable from context** (e.g. a missing empty state, a standard button) → implement autonomously following existing Shuby design patterns
  2. **Complex/ambiguous** (e.g. a new screen layout, a novel interaction) → flag as "needs design" and ask the Shuby design team before implementing
  3. **Contradicted by Figma** (Figma shows something different) → **Figma wins** for visual details
- If FA describes a behavior but Figma shows something different: **Figma wins** for visuals, FA wins for behavior logic
- Flag discrepancies in REMAINING-WORK.md for team clarification

## Scope gate — read this FIRST, before anything else in this rule fires
This rule self-suppresses for **minor edits** even if the file paths match the frontmatter. Minor = single card, component, icon, badge, label, text/i18n, or a one-element spacing/styling tweak. If the current edit is minor, skip the rest of this file; do not open any Figma tool.

The rule applies only to **major edits**: a whole page, a new screen, a redesign, or a coordinated refactor across multiple components.

## Before modifying a view (major edits only)
- Look up the nodeId in `docs/FIGMA-REFERENCE.md` first (local, free).
- Prefer `get_screenshot` for a quick visual reference (image only — medium cost).
- Call `get_design_context` only when the reference + screenshot are insufficient (net-new screens, redesigns, ambiguous components). The fileKey is `qriF7HfsvoG8VUSdjUETBd`.
- If unsure of the nodeId, use `get_metadata` to browse file structure.
- If the view has animations/transitions/prototype interactions, run `bin/figma_prototype_info <nodeId>` for exact timings and target frames (MCP returns only static data). See `docs/FIGMA-REFERENCE.md` → "Animation integration workflow" for the full discover → map → verify recipe and the Figma-transition-to-Shuby-code mapping table.
- Cache within the session; don't re-fetch a nodeId already loaded this session.

## After major visual changes
- Run Playwright screenshot + Figma comparison **once, before PR** (not after each intermediate edit).
- Command: `playwright-cli screenshot --filename=/tmp/shuby-[page].png` (mobile 390x844), then compare against Figma.
- Fix: spacing, colors, typography, border-radius, shadows, icon sizes.
- Do NOT run this after minor edits. If the change touches a single card/icon/badge, stop — the scope gate excludes it.

## Design tokens
- Match Figma colors, font sizes/weights/line-heights, spacing exactly
- Use TailwindCSS v4 custom properties or direct values
- All views designed mobile-first for 390px width
- Tap targets >= 44px (WCAG + Figma)

## Document hierarchy for UI decisions
1. **Figma** — visual source of truth (what it looks like)
2. **FA (Analisi Funzionale)** — behavioral source of truth (how it works)
3. **DECISIONS.md** — client overrides
4. **PRD (Specifiche di Prodotto)** — product-level intent
If Figma omits a PRD feature entirely: it may not be designed yet. Check if it's simple enough to derive from existing patterns, or flag it as "needs design" for the design team.
