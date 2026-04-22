# Upstream issues & workarounds

Bugs in third-party libraries/services where we carry a workaround in the
Shuby codebase. Re-read this file **on every gem upgrade** — workarounds
can be removed once upstream ships a fix, and stale workarounds cause
their own drift.

Format per entry: what, where in our code, how to verify it's still
needed, and the upstream link (once an issue is open).

---

## [PARTIALLY FIXED in 0.8.0, REOPENED] ruby_native — same-tab auto_route cancel

**Symptom.** Tap on a link whose URL matches the currently active tab's
`path`/`auto_route` still triggers `event.preventDefault()` on
`turbo:before-visit` inside the iOS shell. Visit never starts. After 2–9
occurrences the native liquid-glass tab bar stops forwarding any tap to
the webview.

**Evidence (2026-04-22, iPad iOS 18.7, Ruby Native 0.8.0).** After the
0.8.0 upgrade, re-enabling `auto_route: [/today, /children/]` on the
Oggi tab froze the tab bar within 2–3 taps on dashboard widgets
(milestone card → `/children/:id/development-stages/.../start`,
measurement → `/children/:id/measurements/new?type=weight`). Archive
articles (`/archive/:slug`) stayed responsive. The pattern correlates
with deep paths that match the `/children/` trailing-slash prefix.

**What 0.8.0 fixed.** Per release notes + issue #47: trailing-slash
patterns like `/breweries/` now match the bare path `/breweries`, and
`_tabPaths` is grouped by tab index. That addresses one symptom of the
misidentification but the deep-path-match-against-trailing-prefix case
evidently still cancels `turbo:before-visit`.

**Upstream.** https://github.com/ruby-native/gem/issues/47 — the 0.8.0
fix is real but incomplete. Need a new issue (or a comment on #47)
with the 0.8.0 repro captured above.

**Workaround (current).** `config/ruby_native.yml` sets
`auto_route: false` on every tab. Disables the interceptor entirely.
Same tradeoff as before — cross-tab deep-links no longer auto-switch
tabs; users tap the native tab bar manually.

**Files carrying the workaround.**
- `config/ruby_native.yml` — `auto_route: false` on all four tabs.

**Remove workaround when.** A future ruby_native release notes that the
iOS shell's interceptor no longer cancels `turbo:before-visit` for
deep-path matches against trailing-slash auto_route prefixes. Verify
with the debug panel: re-enable `auto_route: [/today, /children/]` on
Oggi, tap through the dashboard milestone + measurement widgets, and
confirm `turbo:before-visit` never logs `def=1` across 10+ navigations.

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
