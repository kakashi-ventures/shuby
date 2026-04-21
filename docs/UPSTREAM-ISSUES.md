# Upstream issues & workarounds

Bugs in third-party libraries/services where we carry a workaround in the
Shuby codebase. Re-read this file **on every gem upgrade** — workarounds
can be removed once upstream ships a fix, and stale workarounds cause
their own drift.

Format per entry: what, where in our code, how to verify it's still
needed, and the upstream link (once an issue is open).

---

## [OPEN] ruby_native 0.7.0 — `turbo:before-visit` cancelled on same-tab match

**Symptom.** Tap on a link whose URL matches the **currently active** tab's
`path`/`auto_route` triggers `event.preventDefault()` on `turbo:before-visit`
inside the iOS shell. The visit never starts — no `turbo:visit`, no fetch,
no render. Webview sits on the current page. After 3–9 occurrences the
native liquid-glass tab bar stops forwarding any tap to the webview at all.

**Expected.** Per gem docs: *"If a link matches the active tab's `path` or
`auto_route` prefixes, navigates within the current tab as usual."*

**Actual (observed 2026-04-21).** iPad iOS 18.7, Ruby Native 0.7.0. Debug
log (via `app/javascript/controllers/debug_panel_controller.js` activated
with `?debug=1` or `cookies[:shuby_debug]`):

```
turbo:click        https://shuby.app/today
turbo:before-visit def=1  https://shuby.app/today
[silence]
```

Desktop Chrome reproduces the flow correctly — bug is purely iOS-side.

**Workaround.** `config/ruby_native.yml` sets `auto_route: false` on every
tab. Disables the interceptor entirely. Tradeoff: cross-tab deep-links no
longer auto-switch tabs (tapping `/children/*` from Archivio stays in
Archivio instead of jumping to Oggi). Users switch tabs manually via the
native tab bar.

**Files carrying the workaround.**
- `config/ruby_native.yml` — `auto_route: false` on Oggi, Shuby AI,
  Archivio, Gestione.

**Reported.** Direct chat with Joe Masilotti (maintainer). No GitHub issue
URL yet — add one here when opened.

**Remove workaround when.** A Ruby Native release notes that the iOS
shell's interceptor no longer cancels `turbo:before-visit` on same-tab
matches. Verify with the debug panel: tap a `/today` link while on the
Oggi tab, confirm `def=1` is NOT present on the `turbo:before-visit` log
line, and confirm `turbo:visit → before-fetch-request → render → load`
fires. Re-enable `auto_route: [/today, /children/, ...]` per tab as
originally intended.

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
