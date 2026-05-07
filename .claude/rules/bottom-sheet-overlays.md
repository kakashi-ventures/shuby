---
paths:
  - "app/javascript/controllers/bottom_sheet_controller.js"
  - "app/javascript/controllers/*overlay_controller.js"
  - "app/assets/tailwind/components/shuby/bottom-sheet.css"
  - "app/assets/tailwind/components/shuby/modals.css"
  - "app/views/**/*overlay*.html.erb"
  - "app/views/shared/dashboard_header/_child_selector*.html.erb"
---

# Bottom-Sheet Overlays

Shuby has three bottom-sheet overlays in production: the dashboard child
selector (`bottom-sheet` controller, opened from the dashboard greeting),
the measurement form (`measurement-overlay` controller, opened from a
"+" button + Turbo frame), and the measurement type picker
(`measurement-picker-overlay` controller, opened from the heading "+" on
the measurements tab). All three share the same visual chrome — only
the surface-specific behavior diverges.

## Architecture

- **Shared CSS**: `app/assets/tailwind/components/shuby/bottom-sheet.css`.
  Provides `.shuby-bottom-sheet`, `.shuby-bottom-sheet--open`,
  `.shuby-bottom-sheet--tall`, `.shuby-bottom-sheet-backdrop`,
  `.shuby-bottom-sheet-sheet`, `.shuby-bottom-sheet-handle`,
  `.shuby-bottom-sheet-spacer`, `.shuby-bottom-sheet-actions`, and
  `.shuby-bottom-sheet-scroll-lock`. Every sheet uses these classes for
  chrome — no per-surface duplication of overlay/backdrop/handle styling.
- **Generic controller**: `app/javascript/controllers/bottom_sheet_controller.js`
  (Stimulus identifier `bottom-sheet`). Handles open/close/Escape/
  scroll-lock/swipe-to-dismiss/backdrop-click. Use directly when the
  sheet has no surface-specific behavior.
- **Surface controllers**: `measurement_overlay_controller.js` and
  `measurement_picker_overlay_controller.js`. Implement the same
  open/close contract standalone (not via JS inheritance — see "Why no
  inheritance" below). Each adds its own behavior on top: form does
  Turbo-frame loading, skeleton restore, and submit-end navigation; the
  picker stays minimal because card taps chain declaratively to the
  form via `data-action`.

## Adding a new bottom sheet

1. **Markup** — wrap your sheet content in the canonical structure:

   ```erb
   <div class="shuby-bottom-sheet"
        data-bottom-sheet-target="overlay"
        aria-hidden="true">
     <div class="shuby-bottom-sheet-backdrop"
          data-action="click->bottom-sheet#close"></div>
     <div class="shuby-bottom-sheet-sheet"
          data-bottom-sheet-target="sheet"
          role="dialog"
          aria-modal="true"
          aria-label="<your label>">
       <div class="shuby-bottom-sheet-handle" aria-hidden="true"></div>
       <%# your content %>
     </div>
   </div>
   ```

2. **Trigger** — wrap the trigger element and the sheet in a host with
   `data-controller="bottom-sheet"` and the open-class data attribute:

   ```erb
   <div data-controller="bottom-sheet"
        data-bottom-sheet-open-class="shuby-bottom-sheet--open">
     <button type="button" data-action="click->bottom-sheet#open">…</button>
     <%= render "your_overlay_partial" %>
   </div>
   ```

3. **Tall variant** — if your sheet uses a flex spacer to push actions
   to the bottom, add `shuby-bottom-sheet--tall` to the outer
   `.shuby-bottom-sheet` so it floors at 480px.

4. **Surface controller** — only needed if you have extra behavior
   (Turbo frames, skeleton restore, post-submit navigation, optimistic
   open). Copy the open/close/scroll-lock/swipe contract from
   `bottom_sheet_controller.js` rather than extending it (see below),
   then add your surface logic. Pick a fresh Stimulus identifier so it
   can coexist with `bottom-sheet` if needed.

## Why no JS inheritance

A previous refactor tried to extend `BottomSheetController` from the
two measurement controllers. It compiled fine but failed at runtime:
Stimulus's static `targets`/`classes` metadata didn't propagate to the
subclasses through importmap-resolved cross-file references — the open
class data attribute ended up empty, so `classList.add(this.openClass)`
silently no-op'd. The pragmatic fix is to treat the CSS classes as the
shared contract and keep the JS implementations standalone. Three small
controllers using the same `.shuby-bottom-sheet-*` chrome is barely
more code than one shared controller — and visual parity is guaranteed
by the CSS, not by the class hierarchy.

If you do introduce a fourth surface, copy the open/close/scroll-lock/
swipe block from one of the existing controllers verbatim. Don't try to
inherit; the trade-off above doesn't change.

## The shape every sheet must implement

Stimulus controller (mirror `bottom_sheet_controller.js` /
`measurement_overlay_controller.js` /
`measurement_picker_overlay_controller.js`):

- `static targets = ["overlay", "sheet", ...]`
- `static classes = ["open"]` — and the **host element MUST carry a
  matching `data-<controller>-open-class="shuby-bottom-sheet--open"`
  attribute**, otherwise `this.openClass` is empty and
  `classList.add("")` silently no-ops.
- `open()` adds the open class, sets `aria-hidden="false"`, locks body
  scroll via the `shuby-bottom-sheet-scroll-lock` body class, binds
  `keydown`.
- `close()` reverses everything; `disconnect()` cleans up.
- `onKeydown` closes on `Escape`.
- Backdrop click is wired declaratively in the partial
  (`data-action="click->...#close"`), NOT via JS.
- Swipe-to-dismiss: 80px threshold, 60px top-of-sheet drag region,
  cancels when starting on a scrollable child or form input.

## Drag handle — canonical spec

Per Figma `315:3672`: 146×6 px, `--color-shuby-black`, `--radius-tondo`,
full opacity, `margin: 0 auto var(--space-4)`. Already encoded on
`.shuby-bottom-sheet-handle`. **Do not customize per surface** — the
drag handle is part of the shared chrome.

## Premium gating inside the sheet

Conditional CTAs (e.g. "+ Aggiungi bambino/a") render through the
existing `policy(...).create?` Pundit gate. To exercise the visible
branch in tests, drop the relevant fixtures down below the limit
inside the test body — fixtures are transactional, so the change
doesn't leak across tests. Don't grow the fixture set just to satisfy
one assertion.

## Test conventions

System test in `test/system/<surface>_overlay_system_test.rb`. Cover at
minimum:

- Trigger opens the overlay (assert on the surface's overlay target +
  `.shuby-bottom-sheet--open`).
- `Escape` closes it.
- Backdrop click closes it.
- Sheet has `role="dialog"` + `aria-modal="true"`.

**Multiple overlays on one page**: the measurements tab renders both
the form overlay AND the picker overlay simultaneously. Both share the
`.shuby-bottom-sheet--open` modifier when open, so test selectors
**must** anchor to the surface's identifier-scoped target attribute to
disambiguate:

```ruby
PICKER_OVERLAY = "[data-measurement-picker-overlay-target='overlay']"
FORM_OVERLAY = "[data-measurement-overlay-target='overlay']"

assert_selector "#{PICKER_OVERLAY}.shuby-bottom-sheet--open"
assert_no_selector "#{FORM_OVERLAY}.shuby-bottom-sheet--open"
```

The **direct-child combinator** matters when finding the trigger:
`find("[data-controller='bottom-sheet'] > button")`. Without `>`,
Capybara matches every descendant `button` (pills, submit buttons
inside the overlay) and errors with `Capybara::Ambiguous`.

## Test-environment quirk: bottom nav intercepts clicks

`.shuby-bottom-nav-fixed` (z-index 50) is hidden globally in the iOS
shell via `hotwire_native.css`, but it renders in Capybara/Selenium and
Selenium's hit-test occasionally reports it as the click receiver for
elements at the bottom of the overlay sheet — even though the overlay
has a higher z-index (110). Use a JS click to bypass:

```ruby
link = find_link(I18n.t("..."))
page.execute_script("arguments[0].click();", link)
```

This is a test-only workaround; production iOS never sees the nav, so
no real CSS fix is required. Do **not** chase z-index escalation to
"fix" this — it's not a real defect.
