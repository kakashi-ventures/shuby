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

## Before modifying any view
- Check Figma design FIRST: `get_design_context` with fileKey `qriF7HfsvoG8VUSdjUETBd`
- Look up the correct nodeId from the Figma Node Map in docs/FIGMA-REFERENCE.md
- If unsure of nodeId, use `get_metadata` to browse file structure
- If the view has animations/transitions/prototype interactions, run `bin/figma_prototype_info <nodeId>` for exact timings and target frames (MCP returns only static data)

## After modifying any view
- Screenshot with Playwright CLI: `playwright-cli screenshot --filename=/tmp/shuby-[page].png` (mobile 390x844)
- Compare against Figma screenshot
- Fix: spacing, colors, typography, border-radius, shadows, icon sizes

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
