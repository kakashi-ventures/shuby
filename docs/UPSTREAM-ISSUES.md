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

## Revisit cadence

- On every `bundle update ruby_native`
- On every major iOS WebKit release (observed bugs may change with WKWebView updates)
- On every Shuby release preparing for App Store submission
