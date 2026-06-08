# Upstream issues & workarounds

Bugs in third-party libraries/services where we carry a workaround in the
Shuby codebase. Re-read this file **on every gem upgrade** — workarounds
can be removed once upstream ships a fix, and stale workarounds cause
their own drift.

Format per entry: what, where in our code, how to verify it's still
needed, and the upstream link (once an issue is open).

---

## [FIXED in 0.8.1] ruby_native — auto_route cancel from unclaimed URLs in Normal Mode

**Root cause (per upstream #50).** `_shouldRouteToOtherTab` inferred the
current tab from `window.location.pathname` via `_matchTab`. When the
webview was on a URL not claimed by any tab's `auto_route` (e.g. after
navigating deep from the Oggi tab to a URL under `/children/` while the
tab's auto_route was `[/today]`, before we added `/children/`), `_matchTab`
returned `null`. A link to a URL that *did* match a tab caused the
interceptor to see `destinationTab !== null` and classify it as a
cross-tab navigation — even though the user was still on the origin tab.
It cancelled `turbo:before-visit` and posted `{action:"visit", url}` to
native. Native saw `matchingTabIndex == selectedIndex` (already on the
correct tab), didn't switch, and called `RubyNative.visit(url)` back
into the same webview, which repeated the cycle. Infinite JS ↔ native
round-trip → `turbo:before-visit def=1` we captured in the debug log.

**Upstream fix.** https://github.com/ruby-native/gem/issues/50 (closed
2026-04-22). Ruby Native 0.8.1 injects `window.RubyNative._myTabIndex`
per-webview from the tab bar controller, so the interceptor compares the
destination against the webview's *actual* tab instead of inferring from
URL. **The fix lives in the native binary**, not the gem — bumping
`ruby_native` alone isn't enough. A fresh TestFlight build via
`ruby_native deploy` is required to pick up the new JS bridge.

**Resolved 2026-04-22.** Upgraded to ruby_native 0.8.1. Restored
`auto_route: [/today, /children/]` on Oggi and default prefix match on
the other three tabs in `config/ruby_native.yml`.

**How to verify the fix holds.** Activate debug panel (`?debug=1` or
`cookies[:shuby_debug]`) on a new TestFlight build. From the Oggi tab
navigate to a non-`auto_route`-claimed URL (e.g. `/children/:id/development-stages`
once the Oggi tab stack is deep), then tap a link back to something
under `/children/`. Confirm `turbo:before-visit` never logs `def=1` and
the native tab bar stays responsive across many navigations.

**Last verified.** ruby_native 0.10.2 (2026-06-04). No regression — fix
remains in the native binary. The deployed iOS binary must be rebuilt
(≥0.8.1) via `ruby_native deploy` to carry it; the gem bump alone doesn't.

---

## [OPEN, since ruby_native ≥ 0.8] gem's `.native-inset-top::before` doubles up on `hide_navbar` pages

**Symptom.** On iOS pages that set `content_for :hide_navbar` (dashboard,
archive show, development-stages), the layout's `<header class="native-inset-top">`
renders an empty `::before` spacer of `env(safe-area-inset-top)` on top of
the page's own safe-area-aware sticky header — visible as a ~47pt empty
blue band above the page header. Chrome (`env() = 0`) is unaffected.

**Root cause.** `ruby_native ≥ 0.8` (gem CSS at
`app/assets/stylesheets/ruby_native.css:5-10`) defines
`.native-inset-top::before { height: env(safe-area-inset-top) }`
unconditionally. Combined with our
`html.hotwire-native #dashboard-header > header { padding-top:
calc(env(safe-area-inset-top) + var(--space-3)) }` rule
(`app/assets/tailwind/components/hotwire_native.css:32-34`), the inset is
injected twice on iOS — once above `<main>` by the gem, once inside the
sticky header by our rule.

**Workaround.** `app/views/layouts/application.html.erb:14` gates the
class:
```erb
<header class="<%= "native-inset-top" unless content_for?(:hide_navbar) %>">
```
Pages with a navbar still get the gem-managed inset; custom-header pages
own theirs locally.

**History.** Same change first shipped as `60375f38` (2026-04-24),
reverted in `e80f768a` on the basis that Ruby Native 0.7's WebView
reported `env(safe-area-inset-top) = 0`. That observation was
version-specific — 0.8.1's WebView exposes the real inset, so the
duplicate-spacer regression is back. Reapplied 2026-04-27.

**Remove workaround when.** The gem ships a way to opt out of the inset
on a per-element basis (e.g. a `--no-inset` modifier or per-page tag),
**or** we move all custom-header pages to a layout that doesn't carry
`<header class="native-inset-top">` at all. To verify the workaround is
still needed: temporarily revert the gating, open the dashboard on iOS,
inspect `<header class="native-inset-top">` in Safari Web Inspector — if
its computed height is non-zero, the workaround is still required.

**Last verified.** ruby_native 0.10.2 (2026-06-04), checked against the gem
source directly. Still open — `app/assets/stylesheets/ruby_native.css` still
injects `.native-inset-top::before { height: … }` unconditionally. NEW in
0.10.x: that height now reads `var(--ruby-native-safe-area-inset-top,
env(safe-area-inset-top))`, so a future cleanup could neutralize the inset
per-element by setting `--ruby-native-safe-area-inset-top: 0` on custom-header
pages instead of gating the class off entirely — evaluate on the next native
pass. For now the class gating in `app/views/layouts/application.html.erb`
(the `<header>` whose `native-inset-top` is dropped on `hide_navbar` /
signed-in pages) is retained.

---

## [OPEN] ruby_native 0.7.0 — UA does not contain "Turbo Native" / "Hotwire Native"

**Symptom.** `turbo-rails`' default `hotwire_native_app?` helper only
matches `/(Turbo|Hotwire) Native/` in the User-Agent. Ruby Native 0.7
sends only `"Ruby Native"` / `"RubyNative/0.7.0"`, so the helper silently
returns `false` in the iOS shell — every `html.hotwire-native` CSS rule
and every server-side native guard fails to fire.

**Workaround.** `app/controllers/concerns/authentication.rb` overrides
`hotwire_native_app?` to match `/(Turbo|Hotwire|Ruby) Native/`. Single
point of UA detection; all 25+ callers in the codebase pick it up via
normal Ruby method lookup.

**Remove workaround when.** Either (a) ruby_native ships a turbo-rails-
compatible UA string (appending `"Turbo Native"` alongside its own
identifier), or (b) turbo-rails adds Ruby Native to its default regex.
Check by removing the override and verifying the html class still applies
on iOS (see `/native_debug` route).

**Last verified.** ruby_native 0.10.2 (2026-06-04). Still open — release
notes through 0.10.2 mention no UA change, and the override remains the
single UA-detection point. Workaround at
`app/controllers/concerns/authentication.rb` retained.

---

## [RESOLVED, was likely a false positive] turbo-rails `< 2.0.21` pin

**History.** Commit `abc3768a` (2026-04-17) pinned turbo-rails to
`< 2.0.21` with the rationale *"Turbo 8.0.21+ removed isSamePage logic,
breaking how visit proposals reach the Ruby Native WKWebView adapter.
Buttons showed :active state but navigation never completed."* Same
commit also added `pointer-events: none` on the invisible native
navbar overlay and removed an unreliable CDN importmap pin.

**Re-evaluation 2026-04-22.** Timeline doesn't support the isSamePage
hypothesis:
- Turbo 8.0.21 (isSamePage removed): released 2026-01-16
- Ruby Native 0.7.0: released 2026-04-10 — three months *after* the
  Turbo removal
- If the gem's iOS adapter depended on isSamePage it would never have
  worked against any current Turbo. Upstream CI would have caught it.

The "button :active but no navigation" symptom matches exactly the
invisible-overlay-intercept fix that shipped in the same commit
(`html.hotwire-native .top-nav.native.fixed { pointer-events: none }`
in `app/assets/tailwind/components/hotwire_native.css`). Most likely
the pin was a coincidental cargo-culted change alongside the actual
fix — both landed together, the pointer-events rule solved it, the
pin got credit.

**Resolution.** Pin removed 2026-04-22. `Gemfile` back to
`gem "turbo-rails", "~> 2.0.3"` — tracking 2.0.23 now (Turbo JS 8.0.23).
No code in this repo referenced the renamed `Turbo.session.navigator`
(only this registry doc mentioned it). Verify on next TestFlight build
that taps still navigate cleanly. If a regression surfaces, re-pin and
reopen with better evidence.

---

## Companion workarounds (same bug class)

These aren't upstream bugs but are narrow compensations for quirks of the
Ruby Native WKWebView environment. Listed so an upgrade pass can revisit
them together.

| Fix | File | Still needed when ruby_native fixes above? |
|---|---|---|
| `data-turbo-prefetch="false"` on `<body>` in native shell | all layouts | Revisit — prefetch-in-WKWebView may be independent of auto_route bug |
| `<meta name="turbo-cache-control" content="no-cache">` in native shell | `app/views/application/_head.html.erb` | Revisit — cache double-render may still desync iOS observer |
| `<meta name="turbo-visit-control" content="reload">` on fullscreen layouts | `stories.html.erb`, `onboarding.html.erb` | Likely still needed — layout-swap into chrome-less pages is a separate concern |
| `data-turbo-permanent` wrapper around `native_tabs_tag` | `application.html.erb` | Likely still needed as a general MutationObserver safety net |
| Skip `/reset_app` redirect for `native_app?` | `authentication.rb` | Keep — `/reset_app` is Hotwire-Native-specific; Ruby Native doesn't intercept it |
| Skip `:native` view variant when `!user_signed_in?` | `device_format.rb` | Keep — unrelated to interceptor; landing page needs standard navbar |

---

# Jumpstart Pro divergences

Not third-party *bugs* — intentional edits to vendored Jumpstart Pro code where its
multi-tenant/team assumptions collide with Shuby's effectively single-account-per-user
model. The `app/` copies shadow `lib/jumpstart/`, so these survive a Jumpstart re-sync
silently. **Revisit on every Jumpstart Pro re-sync** (e.g. `e9b08bff "replace
lib/jumpstart/ with upstream Jumpstart Pro"`) so the divergence is reconciled, not lost.

## [OPEN] "child disappeared after editing profile / switching language" guards

**Bug.** A legacy user owns a `personal:false` account holding their child (registered
while the app was in team mode). The app now runs in personal/both mode, so the first
profile edit fired Jumpstart's name-change callback, which minted an empty `personal:true`
account; `fallback_account` (ordering `personal: :desc`) then preferred the empty account
and the child vanished from the dashboard. Trigger was a phantom `last_name` `NULL → ""`
change posted by the profile form, even when only the language was changed.

**Three Shuby edits diverge from upstream Jumpstart:**

1. `app/models/user.rb` — `normalizes :first_name, :last_name` collapses blank to `nil`
   (`.presence`), so re-submitting an empty field over `NULL` is not a dirty change.
2. `app/models/user/accounts.rb` — `sync_personal_account_name` only syncs an EXISTING
   personal account's name; the upstream `personal_account.nil? → create_default_account`
   branch (which minted the stray) was removed.
3. `app/controllers/concerns/set_current_request_details.rb` — `fallback_account` prefers
   an account holding an active child before the upstream `personal: :desc, created_at:`
   ordering. Safety net so a stranded user still resolves to their child's account.

**Data heal.** `lib/tasks/accounts_reconcile.rake` (`bin/rails accounts:reconcile`,
`APPLY=1` to act) collapses each user to one canonical owned account and destroys only
provably-empty stray owned accounts.

**Remove / reconcile when.** Decide Shuby's account mode deliberately (team vs personal —
currently `account_types: "both"`). If a future Jumpstart sync reorders/removes these, the
regression tests catch it: `test/models/user_test.rb` (normalize + no-account-on-language-
change), `test/controllers/dashboard_controller_test.rb` (child-aware fallback). Re-run
both after any Jumpstart re-sync.

**Caveat.** Child-aware `fallback_account` keys off account *membership*, so a future
multi-account user (premium caregiver sharing, deferred per DEC-004) could be routed toward
a shared child-bearing account on login. Acceptable for v1 (single owned account per user);
pin the active account explicitly when caregiver sharing ships.

---

## Revisit cadence

- On every `bundle update ruby_native`
- On every major iOS WebKit release (observed bugs may change with WKWebView updates)
- On every Shuby release preparing for App Store submission
- On every Jumpstart Pro re-sync (see "Jumpstart Pro divergences" above)
