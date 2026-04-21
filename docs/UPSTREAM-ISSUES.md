# Upstream issues & workarounds

Bugs in third-party libraries/services where we carry a workaround in the
Shuby codebase. Re-read this file **on every gem upgrade** — workarounds
can be removed once upstream ships a fix, and stale workarounds cause
their own drift.

Format per entry: what, where in our code, how to verify it's still
needed, and the upstream link (once an issue is open).

---

## [FIXED in 0.8.0] ruby_native — `turbo:before-visit` cancelled on same-tab match

**Symptom.** Tap on a link whose URL matches the **currently active** tab's
`path`/`auto_route` triggers `event.preventDefault()` on `turbo:before-visit`
inside the iOS shell. The visit never starts. After 3–9 occurrences the
native liquid-glass tab bar stops forwarding any tap to the webview.

**Evidence (2026-04-21, iPad iOS 18.7, Ruby Native 0.7.0).** Debug panel
captured `turbo:before-visit def=1` on a tap from the Oggi tab to `/today`
(Oggi's own path). Desktop Chrome reproduces the flow correctly — bug is
purely iOS-side.

**Root cause (per upstream release notes).** `_tabPaths` was a flat array
instead of grouped-by-tab-index, so `_shouldRouteToOtherTab` misidentified
same-tab navigations as cross-tab. Trailing-slash patterns (`/children/`)
also did not match the bare path, compounding the issue. Triggered an
infinite routing loop when Turbo.js was present in Normal Mode.

**Upstream.** https://github.com/ruby-native/gem/issues/47 (closed
2026-04-21). Fixed in v0.8.0 released the same day — see CHANGELOG
entry *"Tab auto-routing with trailing-slash patterns no longer breaks
Normal Mode navigation."*

**Resolved.** Upgraded to ruby_native 0.8.0 (Gemfile `~> 0.8`). Restored
`auto_route: [/today, /children/]` on the Oggi tab and default prefix
match on the other three. `viewport-fit=cover` added to the viewport
meta tag per the v0.8.0 breaking change (`app/views/application/_head.html.erb`).

**How to verify the fix holds.** Activate debug panel (`?debug=1` or
`cookies[:shuby_debug]`), tap through several `/children/*` links from
within the Oggi tab and from other tabs. Confirm `turbo:before-visit`
never logs `def=1` and the native tab bar stays responsive across many
navigations.

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
