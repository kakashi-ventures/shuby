---
paths:
  - "app/javascript/src/pwa.js"
  - "app/javascript/controllers/pwa_install_controller.js"
  - "app/assets/tailwind/components/shuby/pwa-install.css"
  - "app/views/shared/_pwa_install_instructions_sheet.html.erb"
  - "app/views/**/*pwa_install*.html.erb"
  - "app/views/pwa/service-worker.js"
  - "app/views/application/_head.html.erb"
---

# PWA Install ("Installa l'app")

Shuby is an installable PWA. Two in-app surfaces invite installation while the
hybrid Play/App Store apps stabilize: a dismissible banner on the Oggi
dashboard (`dashboard/_section_pwa_install_banner.html.erb`) and an
always-available row in Impostazioni → Configurazione
(`settings/_section_pwa_install.html.erb`). Both open the shared instructions
sheet `shared/_pwa_install_instructions_sheet.html.erb`. One Stimulus
controller (`pwa-install`) drives every surface; install state lives in the
`src/pwa.js` module.

## The three hide cases — ALL are required

A new install surface MUST disappear in each of these, or it's broken:

1. **Native iOS shell** — server gate. Render `unless hotwire_native_app?`
   (see `ruby-native-ios.md`). Both current surfaces do this at their callsite
   (`dashboard/show.html.erb`, `settings/_tab_configuration.html.erb`).
2. **Installed PWA (standalone)** — client-side, no-flash. The inline script in
   `application/_head.html.erb` adds `html.pwa-standalone` before first paint
   (mirrors the `html.hotwire-native` convention). CSS hides it:
   `html.pwa-standalone .js-pwa-install { display: none !important; }`
   **Every install-surface wrapper carries `.js-pwa-install`.** Add that class
   to any new surface.
3. **Dismissed / installed** — `localStorage`. Keys: `shuby.pwaInstallDismissedAt`
   (banner only, 14-day cooldown) and `shuby.pwaInstalled` (permanent, set by the
   `appinstalled` listener). The banner respects both; the settings row never
   nags (only cases 1–2 hide it).

## `src/pwa.js` is the single source of install state

`beforeinstallprompt` fires at most once early in the session and Turbo visits
never reload the page, so the event is captured (`preventDefault` + stored) at
module scope — that's why the in-app button works on any page, not just the one
open when it fired. The module also listens for `appinstalled` and dispatches
`shuby:pwa-installable` / `shuby:pwa-installed`.

**Reuse its exports — do NOT re-detect anywhere:** `isStandalone()`, `isIOS()`,
`getDeferredPrompt()`, `clearDeferredPrompt()`. Imported via `src/index.js`.

`pwa_install_controller.js#install` branches at tap time: a captured
`beforeinstallprompt` (Android/Chromium) → `prompt()`; otherwise (iOS Safari,
non-Chromium desktop) → open the instructions sheet. The sheet copies the
bottom-sheet open/close/Escape/scroll-lock/swipe contract — **no JS
inheritance** (see `bottom-sheet-overlays.md`).

## Service worker

`app/views/pwa/service-worker.js` + the `service-worker` route in `routes.rb`.
Minimal on purpose: a **navigation-only network pass-through with NO caching**
(zero stale-asset risk). Its sole job is to satisfy the browser's
installability criteria so `beforeinstallprompt` fires.

- **Register the `.js` path**: `navigator.serviceWorker.register("/service-worker.js")`.
  The bare `/service-worker` resolves as an HTML request and **500s** — Rails
  renders the `.js` template only when the format is explicit (same reason the
  manifest `<link>` uses `pwa_manifest_path(format: :json)`).
- Registration is guarded: skipped in the native shell, in non-secure contexts,
  and under `navigator.webdriver` (Selenium) so a worker can't persist and
  intercept navigations across the system-test suite.

## Testing gotchas (these cost real time)

- **Rebuild Tailwind before system tests** when you add/change CSS:
  `bin/rails tailwindcss:build`. `bin/rails test:system` uses the prebuilt
  `app/assets/builds/tailwind.css`; a stale build silently omits new rules (e.g.
  the `html.pwa-standalone` hide), so the test fails for a non-obvious reason.
- **`beforeinstallprompt` can't be triggered for real in Selenium.** System
  tests cover the no-prompt path (instructions sheet), dismiss persistence, and
  standalone hide (inject `html.pwa-standalone` via `execute_script`). To reveal
  the banner deterministically, dispatch a synthetic `new Event('beforeinstallprompt')`.
  The real native-prompt path is verified via Playwright, where
  `navigator.webdriver` is false → the SW registers and the event fires on
  localhost.
- **`t()` output is HTML-escaped.** Assert against
  `ERB::Util.html_escape(I18n.t(...))` for strings with an apostrophe (e.g.
  "Installa l'app sul telefono" → `l&#39;app`), or an absence assertion becomes a
  false positive.

## i18n

All copy under `pwa.install.*` (`config/locales/it.yml` + `en.yml`). Sheet steps
are YAML arrays (`ios_steps`, `generic_steps`) iterated in the partial.
