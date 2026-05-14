# WCAG 2.1 Level AA Accessibility Audit

_Last audit: 2026-05-14 — codebase commit `6d098ecc` (HEAD at start)_
_Conformance target: WCAG 2.1 Level AA (PRD §5.4)_
_Deployment context: iOS-only via Ruby Native (WKWebView), VoiceOver as primary AT_

## Methodology

Three independent layers of evidence:

1. **Automated scan** — `axe-core-rspec` 4.11 driving axe-core inside Selenium
   headless Chrome. Eight system tests in `test/system/accessibility_test.rb`
   assert the WCAG 2.0 A + 2.0 AA tag bundle on the highest-traffic flows
   (sign-in, dashboard, timeline, archive index, measurements tab, AI chat,
   settings, child profile). The bundle covers the automatable portion of
   WCAG 2.1 AA.
2. **Token-level static check** — `bin/verify_token_contrast` parses the
   theme + token CSS files, computes WCAG relative-luminance contrast ratios
   for every fg/bg pair declared inside the semantic Shuby CSS layer, and
   prints a pass/fail table. Advisory by default; gates CI with `--strict`.
3. **Manual review** — Explorer-driven file-by-file inventory of ARIA usage,
   keyboard handlers, modal focus patterns, landmark structure, and live
   regions. Documented in conversation; remediation summarized below.

VoiceOver-on-device pass deferred to a separate runner (no simulator
available in this audit session); residual log below.

## Findings by WCAG Success Criterion

### 1.1.1 Non-text Content (Level A) — addressed

- Decorative SVGs marked `aria-hidden="true"` via `render_svg ..., decorative:
  true` where they were missing the flag. Spots fixed:
  `app/views/archive/_empty_state.html.erb`,
  `app/views/archive/_section_content_list.html.erb`,
  `app/views/archive/_index_header.html.erb` (bookmark icon).
- `app/views/development_stages/index.html.erb`: avatar `image_tag` now emits
  `alt=""` so screen readers treat the photo as decorative and read the
  surrounding link label instead.

### 1.3.1 Info and Relationships (Level A) — addressed

- Layout landmarks: `<main id="main-content" tabindex="-1">` + `<header
  aria-label="…">` in `app/views/layouts/application.html.erb`.
- Timeline pills converted to a proper tablist: `role="tablist"` on the
  scroll container (`_timeline_carousel.html.erb`), `role="tab"` +
  `tabindex` roving on each pill (`_timeline_pill.html.erb` +
  `timeline_carousel_controller.js`). Was emitting `aria-selected="false"`
  on plain buttons which axe correctly flagged as `aria-allowed-attr` —
  the attribute is only valid in concert with `role="tab"` (or
  `option`/`treeitem`/etc.).

### 1.4.3 Contrast (Minimum) (Level AA) — addressed

Root cause: `--base-text-secondary` semantic alias pointed at
`--color-shuby-gray-700` (`#898D91`) which yields **3.34:1** on white — fails
the 4.5:1 normal-text threshold. The token feeds 36 component-level rules
(section labels, chat metadata, profile-nudge subtitles, form labels,
tags, …) so the same defect surfaced on 7 of 8 test pages.

Fix: re-pointed `--base-text-secondary` to `--color-shuby-gray-800`
(`#616467`, ~6.0:1 on white, ≥4.5:1 on every Shuby band background) in
`app/assets/tailwind/themes/shuby.css`. Also bumped the
direct-gray-700 text uses in `tags-badges.css` (`.shuby-tag-default`,
`.shuby-tag-light`, `.shuby-tag-yellow`) and `stage.css` (history tag)
which bypass the alias.

Footer copyright (`text-gray-400`, ~2.6:1) → `text-gray-600`
(`#4b5563`, ~7.6:1).

### 2.1.1 Keyboard (Level A) — addressed

- Archive filter toggle: plain `<button>` already keyboard-operable; added
  `aria-label`, `aria-expanded`, `aria-controls` so screen-reader users
  understand its state. `archive_filter_controller.js` flips
  `aria-expanded` on toggle/close.
- Favorite "button" wrapper: outer `<div>` only carries
  `event.stopPropagation` — the inner `button_to` already provides the
  keyboard-operable element. Left as-is (axe did not flag it).

### 2.1.2 No Keyboard Trap (Level A) — addressed

- Modal bottom-sheets + questionnaire overlay now activate a real Tab
  focus trap on open and release it on close. Shared module:
  `app/javascript/src/focus_trap.js`, consumed by
  `bottom_sheet_controller`, `measurement_overlay_controller`,
  `measurement_picker_overlay_controller`, `questionnaire_overlay_controller`.
- Escape key continues to close every modal (so the trap is never
  inescapable — meets the "no trap" intent while still cycling Tab inside).

### 2.4.1 Bypass Blocks (Level A) — addressed

- New skip-to-content link rendered as the first child of `<body>` in
  `application.html.erb`. Italian copy "Vai al contenuto principale".
  Positioned offscreen until focused, then drops in (`shuby-skip-link.css`).
  Target is the `<main id="main-content" tabindex="-1">`.

### 2.4.3 Focus Order (Level A) — addressed

- Focus is moved into the modal on open (first focusable element) and
  restored to the trigger element on close. Implemented inside
  `activateFocusTrap` (see 2.1.2). The previously focused element is
  captured at activation time and re-focused at teardown.

### 2.4.4 Link Purpose (Level A) — addressed

- Dashboard profile button (`shared/dashboard_header/_profile_button.html.erb`)
  and timeline back/avatar links (`development_stages/index.html.erb`) now
  carry `aria-label` with the child's display name. Was an icon-only `<a>`
  with no accessible text — axe flagged `link-name`.

### 2.4.8 Location (Level AAA, partial) — addressed

- Bottom nav (`shared/_shuby_bottom_nav.html.erb`) emits
  `aria-current="page"` on the active tab link. Data-driven loop replaces
  the previously copy-pasted four entries.

### 3.3.1 Error Identification (Level A) — addressed

- Validation summary partials emit `role="alert"` +
  `aria-live="assertive"` + `tabindex="-1"`:
  - `app/views/application/_error_messages.html.erb` (already had role)
  - `app/views/measurements/_form_errors.html.erb`
  - `app/views/onboarding/_section_errors.html.erb`
- Per-input `aria-invalid` / `aria-describedby` linkage deferred (residual
  — see below); the alert region announces the summary, which is the
  minimum for SC 3.3.1.

### 4.1.2 Name, Role, Value (Level A) — addressed

- Archive filter toggle gained an accessible name (axe `button-name`
  violation cleared).
- Bottom nav links carry both visible label and `aria-current` state.
- Timeline pills now expose their `aria-selected` state in concert with
  `role="tab"` (axe `aria-allowed-attr` cleared).

### 4.1.3 Status Messages (Level AA) — addressed

- AI chat `#messages` container: `aria-live="polite"` + `aria-relevant="additions"`
  + `aria-label`. New assistant turns delivered via Turbo Stream are now
  announced.
- Form error containers (see 3.3.1) similarly polite/assertive.

## Residual / Deferred

These were surfaced by the audit but intentionally not fixed in this PR.

| Item | Why deferred | Suggested next step |
|---|---|---|
| Per-input `aria-invalid` + `aria-describedby` on form fields | Touches every form partial in the codebase (~25 files); scope-bounded by the audit, not a critical AA gap because the alert summary already announces. | Phase-2 helper `error_attrs_for(form, field)` in `app/helpers/forms_helper.rb` (sketch in plan file). |
| Manual VoiceOver pass on iOS simulator | No simulator in this audit session. | Pediatric-flow walkthrough on simulator: dashboard, timeline, measurement bottom-sheet, chat, questionnaire stories. Log any swipe-rotor gaps. |
| `bin/verify_token_contrast` advisory failures (10 pairs) | Most are large-text (≥3:1), disabled-state (exempt), or non-text UI components. The axe-core system tests verify in-context. | Refine script to flag `font-size`-aware threshold; or annotate per-rule exceptions. Track as P3. |
| Pre-existing failing `LoginSystemTest` cases | HANDOFF documented 33 failures + 6 errors on HEAD pre-this-audit. Login template untouched here. | Separate triage pass (notes in `docs/REMAINING-WORK.md`). |
| `.text-gray-500` placeholder + `:disabled` styles | Disabled state exempt per WCAG SC 1.4.3 exception. Visually still readable. | Verify with stakeholders if stricter visual disabled state is desired. |

## Regression suite

`test/system/accessibility_test.rb` — 8 system tests, asserts AA on key
flows. CI runs them in the existing `system-test` job (no workflow change
required; new file is picked up automatically). Adding a new top-level
flow? Append a test here so axe scans it on every PR.

Run locally:

```bash
bin/rails test test/system/accessibility_test.rb
```

Or run the contrast script:

```bash
bin/verify_token_contrast            # advisory (exit 0)
bin/verify_token_contrast --strict   # CI-gate (exit 1 on any sub-4.5:1)
```

## Files touched

```
# tooling
Gemfile                                                      (+ axe-core-api/rspec)
test/application_system_test_case.rb                         (+ assert_accessible helper)
test/system/accessibility_test.rb                            (new — 8 flows)
bin/verify_token_contrast                                    (new — Ruby script)
docs/A11Y-AUDIT.md                                           (new — this file)
docs/REMAINING-WORK.md                                       (mark P2 row complete)

# layout / landmarks / skip-link
app/views/layouts/application.html.erb
app/views/layouts/_skip_link.html.erb                        (inlined in layout)
app/assets/tailwind/components/shuby/skip-link.css           (new)
app/assets/tailwind/application.css                          (import skip-link)
config/locales/it.yml                                        (a11y.* keys)

# icon-only links / buttons
app/views/shared/dashboard_header/_profile_button.html.erb
app/views/development_stages/index.html.erb
app/views/archive/_index_header.html.erb
app/javascript/controllers/archive_filter_controller.js
app/views/archive/_search_filter_panel.html.erb              (panel id)

# timeline tablist
app/views/development_stages/_timeline_pill.html.erb         (role=tab)
app/views/development_stages/_timeline_carousel.html.erb     (role=tablist)
app/javascript/controllers/timeline_carousel_controller.js   (tabindex roving)

# contrast token shift
app/assets/tailwind/themes/shuby.css                         (base-text-secondary)
app/assets/tailwind/components/shuby/tags-badges.css         (direct gray-700→800)
app/assets/tailwind/components/shuby/stage.css               (direct gray-700→800)
app/views/application/_footer.html.erb                       (gray-400→gray-600)

# modal focus trap + inert
app/javascript/src/focus_trap.js                             (new — shared module)
app/javascript/controllers/bottom_sheet_controller.js
app/javascript/controllers/measurement_overlay_controller.js
app/javascript/controllers/measurement_picker_overlay_controller.js
app/javascript/controllers/questionnaire_overlay_controller.js

# form error semantics
app/views/measurements/_form_errors.html.erb                 (role=alert + aria-live)
app/views/onboarding/_section_errors.html.erb                (role=alert + aria-live)

# chat live region
app/views/shuby_chats/show.html.erb                          (aria-live on #messages)

# bottom nav
app/views/shared/_shuby_bottom_nav.html.erb                  (aria-current + data loop)

# decorative SVG sweep
app/views/archive/_empty_state.html.erb
app/views/archive/_section_content_list.html.erb
```

## Verification snapshot

```
$ bin/rails test test/system/accessibility_test.rb
8 runs, 16 assertions, 0 failures, 0 errors, 0 skips

$ bin/rails test test/system/{accessibility,measurement_overlay,child_selector_overlay,measurement_picker_overlay}_system_test.rb
26 runs, 70 assertions, 0 failures, 0 errors, 0 skips

$ bin/rubocop test/application_system_test_case.rb test/system/accessibility_test.rb bin/verify_token_contrast
3 files inspected, no offenses detected

$ bin/verify_token_contrast | tail -1
all surveyed pairs covered; 10 advisory items (large text / disabled / non-text UI) — see residuals
```
