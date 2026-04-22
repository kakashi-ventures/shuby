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

## [OPEN] turbo-rails pinned to `< 2.0.21` — Turbo JS 8.0.21 removed isSamePage

**Symptom.** Turbo 8.0.21 removed the `isSamePage` logic that Ruby
Native's iOS WKWebView adapter relied on. Observed (commit `abc3768a`,
2026-04-17): buttons/links showed `:active` state on tap but navigation
never completed inside the native shell.

**Workaround.** `Gemfile` pins `turbo-rails "~> 2.0.3", "< 2.0.21"`,
keeping us on turbo-rails 2.0.20 / Turbo JS 8.0.20. Every subsequent
turbo-rails release (2.0.21, 2.0.22, 2.0.23) bundles Turbo JS 8.0.21+,
so we can't bump within the pin range.

**Checked 2026-04-22.** ruby_native 0.8.0 CHANGELOG makes no mention of
Turbo adapter changes; the gem's own source has no `isSamePage` /
`visitProposedToLocation` references (adapter lives in the closed iOS
Swift side). No evidence the native shell works with Turbo 8.0.21+.

**Remove workaround when.** A future ruby_native release notes explicit
support for Turbo 8.0.21+ (post-isSamePage), OR turbo-rails itself
re-introduces an equivalent same-page signal. Test by lifting the pin
to `~> 2.0.3`, running `bundle update turbo-rails`, building TestFlight,
and confirming that dashboard link taps still navigate (not just
:active then sit).

**Files carrying the workaround.**
- `Gemfile` — line 17: `gem "turbo-rails", "~> 2.0.3", "< 2.0.21"`.

**Patches we're missing while pinned.** As of 2026-04-22: 2.0.23.
Mostly dependency freshening and one `session.navigator` rename. Low
severity — no known critical fixes in this window.

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
