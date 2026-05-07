---
paths:
  - "app/javascript/controllers/*overlay_controller.js"
  - "app/assets/tailwind/components/shuby/modals.css"
  - "app/views/**/*overlay*.html.erb"
---

# Bottom-Sheet Overlays

Shuby has two bottom-sheet overlays in production: the measurement overlay
(`measurement_overlay_controller`, opened by the `+` buttons) and the child
selector overlay (`child_selector_overlay_controller`, opened by the dashboard
greeting). Both follow the same shape; pick the right strategy when adding a
third.

## The shape every sheet must have

Stimulus controller (mirror `measurement_overlay_controller.js` or
`child_selector_overlay_controller.js`):

- `static targets = ["overlay", "sheet", ...]`
- `static classes = ["open"]` — and the **host element MUST carry a
  matching `data-<controller>-open-class="..."` attribute**, otherwise
  `this.openClass` is empty and `classList.add("")` silently no-ops.
- `open()` adds the open class, sets `aria-hidden="false"`, locks body
  scroll via a `<controller>-scroll-lock` body class, binds `keydown`.
- `close()` reverses everything; `disconnect()` cleans up.
- `onKeydown` closes on `Escape`.
- Backdrop click is wired declaratively in the partial (`data-action="click->...#close"`), NOT via JS.
- Swipe-to-dismiss: 80px threshold, 60px top-of-sheet drag region,
  cancels when starting on a scrollable child or form input.

CSS (in `app/assets/tailwind/components/shuby/modals.css`, parallel to
`.shuby-measurement-overlay-*`):

- `position: fixed; inset: 0; z-index: 110; pointer-events: none;
  visibility: hidden;` — flipped when the open modifier is present.
- Sheet anchored to bottom via `flex-direction: column; justify-content: flex-end`.
- `border-top-{left,right}-radius: var(--radius-grande)` only.
- `padding-bottom: calc(var(--space-6) + env(safe-area-inset-bottom))` to
  clear the iOS home indicator. Web browsers resolve the inset to 0 so this
  is unconditional.
- Sheet `transform: translateY(100%) → 0` with `transition: transform
  250ms ease-out`. Backdrop fades 0 → 1 over 200ms.

ERB partial:

- Outer `.<name>-overlay` with `data-<name>-target="overlay"` +
  `aria-hidden="true"`.
- `.<name>-overlay-backdrop` sibling with the click-to-close action.
- `.<name>-overlay-sheet` with `role="dialog"` + `aria-modal="true"` +
  meaningful `aria-label`, `data-<name>-target="sheet"`.
- `.<name>-overlay-handle` decorative drag affordance (40×4, `--radius-tondo`,
  blue-800 50% opacity).

## Clone vs share — pick once, document why

The two existing sheets clone the scaffolding under different namespaces
(`.shuby-measurement-overlay-*` vs `.shuby-child-selector-overlay-*`)
rather than share a base class. The reason was tactical: both surfaces
were still evolving when each shipped, so a shared base would have
generated rebase risk on in-flight UX work.

When adding a third sheet:

- **If the existing sheets have stabilized**, refactor first. Promote the
  shared shape into `.shuby-bottom-sheet-*` (CSS) and a base
  `bottom_sheet_controller` (JS) that the per-surface controllers extend.
  Migrate the existing two as part of the same PR.
- **If they're still in flux**, clone the scaffolding under a fresh
  namespace (third surface), follow the shape above exactly, and add a
  TODO at the top of the new CSS section pointing back to this rule.

Either way, do not bury new behavior in a third controller without
verifying it against the shape — divergence here regresses the swipe /
backdrop / escape contract the user expects across all sheets.

## Test conventions

System test in `test/system/<surface>_overlay_system_test.rb`. Cover at
minimum:

- Trigger opens the overlay (`assert_selector ".<name>-overlay--open"`).
- `Escape` closes it.
- Backdrop click closes it.
- Sheet has `role="dialog"` + `aria-modal="true"`.

The **direct-child combinator** matters when finding the trigger:
`find("[data-controller='<name>'] > button")`. Without `>`, Capybara
matches every descendant `button` (pills, submit buttons inside the
overlay) and errors with `Capybara::Ambiguous`.

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

## Premium gating inside the sheet

Conditional CTAs (e.g. "+ Aggiungi bambino/a") render through the
existing `policy(...).create?` Pundit gate. To exercise the visible
branch in tests, drop the relevant fixtures down below the limit
inside the test body — fixtures are transactional, so the change
doesn't leak across tests. Don't grow the fixture set just to satisfy
one assertion.
