---
paths:
  - "app/views/dashboard/**"
  - "app/views/development_stages/**"
  - "app/views/archive/**"
  - "app/views/shared/dashboard_header/**"
  - "app/javascript/controllers/**"
  - "app/assets/tailwind/components/shuby/**"
---

# Functional Analysis — UI Behaviors

Screen-level details from `docs/Shuby - Analisi Funzionale - v.1.0.pdf` not captured in the PRD.
Cross-reference these when implementing or reviewing any screen.

## Dashboard (Oggi) — 5 Bands

1. **Eta e fase di crescita**: Growth phase with illustration, title, description. Updates weekly until week 8, monthly until ~18mo, then every 2-3 months.
2. **Tappa di sviluppo**: Daily clickable milestone box cycling through incomplete milestones. Three states: proposed (invitation CTA), completed (with "Scopri le altre Tappe" link), all-done (congratulations message).
3. **Attivita**: 2 activity boxes (from Archive, age-appropriate, daily cycling) + 2 measurement boxes. Measurement boxes have 3 states: start tracking (never tracked), existing (last date shown), needs update (colored urgency background).
4. **Consigli di oggi**: 3 daily advice cards. Two types: reading (book with author/publisher/cover) and other (games/activities with time estimate). "Tutti i consigli" cross-link to Archive.
5. **Articoli in primo piano**: Horizontal scrollable carousel of 4+ articles selected by age + user behavior. "Tutti gli articoli" cross-link to Archive.

## Dashboard Header Scroll Behavior
- Sticky on top during scroll
- Background color transitions: blue (matching first band) -> white (after scrolling past first band)
- Smooth color transition

## Timeline Carousel Pill States
- **Current** (filled): child's actual age, default pre-selected on load
- **Past** (light fill): phases before current
- **Future** (outline, faded): phases not yet reached — locked for free users
- **Selected** (magenta/accent): temporary overlay on any pill, triggers content reload

## Timeline Milestone Interaction Rules
- Current age: interactive, can recompile unlimited times, prior data preserved in reports
- Past age: view-only, shows "Completata" + date or "Tappa passata", no interaction
- Future age: non-interactive, counter always "0 completate", "Tappa futura" tag

## Archive Filter Overlay (FA 6.1.1.1)
- Filters: age bracket, content type (article/advice/activity), standard tags per type, free-text keyword search bar
- Bookmarks button links to saved favorites section

## Article Detail Scroll Effect (FA 6.2.1)
- Full-width image at top
- White content area slides up and overlaps image during scroll
- Title + bookmark become sticky header
- Back button repositions next to title
- Subtle white fade below sticky title
- Scrolling back up restores full image layout

## Advice/Activity Detail Variants (FA 6.2.2)
- Book content: same as article, with book cover image
- No-image content: short colored band at top instead (blue for activities, yellow for advice)
- Same scroll behavior applies
