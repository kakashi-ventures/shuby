# Session Handoff

_Last updated: 2026-04-24_

## What Was Done

### P2 Measurements — finished 3 in-flight features (awaiting commit)

The working tree carries ~35 modified/new files across 3 measurement features
that were implemented but never committed between 2026-04-14 and today. The
code is now tested, Figma-verified, and UX-polished. **Nothing committed yet —
the user asked to review the diff before deciding how to split commits.**

1. **Photo upload** (PRD 3.5.2) — Active Storage `has_one_attached :photo`,
   form preview + remove flag, PDF JPEG thumbnail, validations (content-type
   whitelist + 10 MB max). Full coverage: model tests (size, content-type,
   JPEG/PNG/HEIC) + controller tests (create with photo, purge on
   `remove_photo=1`, reject non-image).

2. **Unit of measure preference** — `User::MeasurementUnit` concern stored in
   `users.preferences` JSONB, segmented toggle in `/settings/privacy`, inline
   overlay toggle that fire-and-forgets a PATCH to persist the pref, display
   helpers (`measurement_display`, `measurement_unit_label_for_type`). PDF
   intentionally stays metric (Italian pediatric convention — documented in
   `report_data_aggregator.rb:109`). Full coverage: unit test + controller test.

3. **Bottom-sheet overlay for new measurement** — new `_overlay.html.erb`
   partial + `measurement_overlay_controller.js` Stimulus controller. Wired
   to every `+` button (dashboard cards, measurements tab cards, empty-state
   grid) via the new `measurement_overlay_link_data` helper.

### Overlay UX upgrade this session — optimistic open + skeleton

- Flipped `openWithFrame` to call `open()` BEFORE setting the frame src so
  the sheet animates up immediately. The previous behavior waited for
  `turbo:frame-load` before opening, causing a visible delay on slow
  connections.
- Added `_overlay_skeleton.html.erb` (title bar + 2 field rows + CTA) that
  renders inside the turbo_frame by default, then gets replaced when the
  real form arrives.
- Added `.shuby-measurement-overlay-skeleton-*` CSS with 1.2s shimmer
  animation in `modals.css`.
- `close()` restores the skeleton via a `<template>` target clone so
  reopening the overlay shows the skeleton again instead of the previous
  response.
- Added `MeasurementOverlaySystemTest` (3 Capybara tests covering
  optimistic open, Escape close, backdrop close). All green in 2.6s.

### Figma parity pass

Fetched nodeIds `621:9860` (overlay), `436:4638` (empty tab), `451:5043`
(tab with data), `413:3671` (card component) from fileKey
`qriF7HfsvoG8VUSdjUETBd`. Implementation matches:
- Overlay sheet background `blue-500 (#9ec6f0)` ✓
- Underline fields with uppercase labels + blue-700 bottom border ✓
- Unit toggle (88×36 px, blue-800 active pill on blue-400 track) ✓
- Save CTA label "Salva modifiche" ✓
- Card split layout (white info left, blue-400/grey-400 value right) ✓

## Test status

- Measurement-focused suite: `71/71 passing` across model, helper,
  controller, and privacy-settings controller tests.
- Overlay system test: `3/3 passing`.
- Full suite: **33 failures + 6 errors pre-exist on HEAD** (accounts, multi-
  tenancy, AI service article catalog, Jumpstart config tests) — verified by
  stashing all uncommitted work and re-running. These are NOT caused by the
  measurement changes.
- Rubocop: clean on all modified Ruby files.

## In Progress

Nothing in progress — all three P2 measurement features are complete.
Waiting on user to review the diff and decide commit granularity.

## Suggested commit split

- Commit 1 (Unit prefs): `app/models/user/measurement_unit.rb`, `app/models/user.rb` include, `app/controllers/settings/privacy_controller.rb`, `app/views/settings/privacy/show.html.erb`, `app/views/measurements/_unit_toggle.html.erb`, form.js toggle logic, `app/helpers/measurements_helper.rb`, `app/models/measurement.rb` IMPERIAL constant + display methods, `app/services/report_data_aggregator.rb`, related tests + locales.
- Commit 2 (Photo upload polish): form.html.erb preview/remove UI, form.js photo-change handlers, controller/model photo tests, it.yml/en.yml strings. (Base photo feature already shipped in `fdc3f8b3`.)
- Commit 3 (Overlay + empty state + CSS): `_overlay.html.erb`, `_overlay_skeleton.html.erb`, `_measurements_empty_state.html.erb`, `measurement_overlay_controller.js`, link helper, dashboard/card_metric/measurements_tab wiring, `modals.css` overlay styles, `cards.css` empty-state styles, `measurement_overlay_system_test.rb`.

## Blockers

- **Stripe plans**: pricing unconfirmed (PRD: 7.99€/mo, PDF: 6€/mo) — cannot configure actual plans.
- **AI chat limit**: code has 30 msgs/month (DEC-005), PDF says 8 — needs client confirmation.
- **"Tappe di sviluppo collegate"**: needs content-to-development-area association model, not yet designed.

## Next Steps

1. Review uncommitted measurement diff and commit in 3 groups (or merge into one if preferred).
2. Next P2 unchecked item: "Verify 3-state milestone box in dashboard (proposed/completed/all-done per FA 3.3)". Dashboard-scoped, independent from measurements.
3. Remaining P1: Report section selection UI (PRD 3.8), notification system.
4. Pre-existing failing tests worth a separate triage pass — not blocking but noisy.

## Recent Commits

```
c4a50c2f Merge branch 'main' of https://github.com/ameft-kva/shuby
24a45795 fix: hide global Shuby-logo navbar on Timeline page
693876b8 fix: force full navigation into fullscreen stories layout
529355ed debug: allow toggling debug panel from Gestione (beta tester only)
ca073fca docs: Figma animation integration workflow (discover → map → verify)
```
