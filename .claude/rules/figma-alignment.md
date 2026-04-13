---
paths:
  - "app/views/**/*.erb"
  - "app/components/**/*.rb"
  - "app/assets/tailwind/**"
  - "app/helpers/**_helper.rb"
---

# Figma Design Alignment

## Before modifying any view
- Check Figma design FIRST: `get_design_context` with fileKey `qriF7HfsvoG8VUSdjUETBd`
- Look up the correct nodeId from the Figma Node Map in CLAUDE.md
- If unsure of nodeId, use `get_metadata` to browse file structure

## After modifying any view
- Screenshot with Playwright CLI: `playwright-cli screenshot --filename=/tmp/shuby-[page].png` (mobile 390x844)
- Compare against Figma screenshot
- Fix: spacing, colors, typography, border-radius, shadows, icon sizes

## Design tokens
- Match Figma colors, font sizes/weights/line-heights, spacing exactly
- Use TailwindCSS v4 custom properties or direct values
- All views designed mobile-first for 390px width
- Tap targets >= 44px (WCAG + Figma)
