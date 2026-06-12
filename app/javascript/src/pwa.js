// PWA bootstrap — runs once when the page first loads (imported from
// src/index.js). Two responsibilities:
//
//   1. Register the service worker, which is what lets Chrome/Android fire
//      `beforeinstallprompt` (the install criteria require a registered SW
//      with a fetch handler — see app/views/pwa/service-worker.js).
//   2. Capture the install lifecycle. `beforeinstallprompt` fires at most
//      once early in the session and Turbo visits never reload the page, so
//      the event is held here at module scope — that way the in-app
//      "Installa" button works on ANY page (dashboard, settings), not just
//      the one that happened to be open when the event fired.
//
// The pwa-install Stimulus controller consumes the helpers + custom events
// below. Keep DOM/UI concerns out of this file.

let deferredPrompt = null

// True when the app is running as an installed PWA (standalone display) —
// Chromium/Android via the display-mode media query, iOS via the legacy
// navigator.standalone flag. In that case the install prompts must stay
// hidden (you can't install what's already installed).
export function isStandalone() {
  return (
    window.matchMedia("(display-mode: standalone)").matches ||
    window.navigator.standalone === true
  )
}

// True on iOS Safari, where `beforeinstallprompt` does not exist and the
// user installs manually via the Share sheet → "Aggiungi a Home". iPadOS 13+
// reports a desktop-Mac UA, so we disambiguate with touch-point count.
export function isIOS() {
  const ua = window.navigator.userAgent || ""
  return (
    /iphone|ipad|ipod/i.test(ua) ||
    (navigator.platform === "MacIntel" && navigator.maxTouchPoints > 1)
  )
}

// The captured BeforeInstallPromptEvent, or null when the browser has not
// offered one (iOS, non-Chromium desktop, or already installed).
export function getDeferredPrompt() {
  return deferredPrompt
}

// Drop the captured event after it has been used — it can only be prompt()ed
// once.
export function clearDeferredPrompt() {
  deferredPrompt = null
}

function isNative() {
  return document.documentElement.classList.contains("hotwire-native")
}

// Capture the install prompt instead of letting Chrome show its own
// mini-infobar, so we can trigger it from our in-app button on demand.
window.addEventListener("beforeinstallprompt", (event) => {
  event.preventDefault()
  deferredPrompt = event
  window.dispatchEvent(new CustomEvent("shuby:pwa-installable"))
})

// Once installed, remember it permanently and let any open prompt UI hide
// itself.
window.addEventListener("appinstalled", () => {
  deferredPrompt = null
  try {
    localStorage.setItem("shuby.pwaInstalled", "1")
  } catch (e) {
    // localStorage can throw in private mode — non-fatal.
  }
  window.dispatchEvent(new CustomEvent("shuby:pwa-installed"))
})

// Register the service worker. Skipped in the native iOS shell (no point)
// and outside secure contexts (SW registration would throw). Failures are
// swallowed: the install surfaces simply fall back to manual instructions.
function registerServiceWorker() {
  if (isNative()) return
  // Skip under automated browsers (Selenium) — a registered worker would
  // persist and intercept navigations across the system-test suite. The
  // worker itself is covered by the integration test.
  if (navigator.webdriver) return
  if (!("serviceWorker" in navigator)) return
  if (!window.isSecureContext) return

  // Register the .js path: the route serves the worker with a text/javascript
  // MIME type only when the format is explicit (the bare /service-worker path
  // resolves as HTML and 500s). Scope defaults to "/" (the script directory).
  navigator.serviceWorker.register("/service-worker.js").catch(() => {
    // Non-fatal — one-tap install won't be available, manual still works.
  })
}

registerServiceWorker()
