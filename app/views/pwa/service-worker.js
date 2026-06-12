// Minimal service worker.
//
// Its only job today is to satisfy the browser's PWA installability
// criteria — Chrome/Android require a registered service worker with a
// fetch handler before they fire `beforeinstallprompt`, which is the event
// that lets us offer an in-app "Installa" button (see src/pwa.js +
// pwa_install_controller.js). It does NOT cache anything: every request
// goes straight to the network, so there is zero risk of serving stale
// assets. Offline support / push notifications can be layered on later.

self.addEventListener("install", () => {
  // Activate this worker as soon as it finishes installing.
  self.skipWaiting()
})

self.addEventListener("activate", (event) => {
  // Take control of already-open clients without requiring a reload.
  event.waitUntil(self.clients.claim())
})

self.addEventListener("fetch", (event) => {
  // Network pass-through for top-level navigations only. Calling
  // respondWith here makes this a non-trivial fetch handler (what the
  // installability check looks for) while leaving asset/XHR/streaming
  // requests untouched (they fall through to the browser's default).
  if (event.request.mode === "navigate") {
    event.respondWith(fetch(event.request))
  }
})

// Web Push notifications can be added here later:
//
// self.addEventListener("push", async (event) => {
//   const { title, options } = await event.data.json()
//   event.waitUntil(self.registration.showNotification(title, options))
// })
//
// self.addEventListener("notificationclick", function (event) {
//   event.notification.close()
//   event.waitUntil(
//     clients.matchAll({ type: "window" }).then((clientList) => {
//       for (let i = 0; i < clientList.length; i++) {
//         let client = clientList[i]
//         let clientPath = (new URL(client.url)).pathname
//
//         if (clientPath == event.notification.data.path && "focus" in client) {
//           return client.focus()
//         }
//       }
//
//       if (clients.openWindow) {
//         return clients.openWindow(event.notification.data.path)
//       }
//     })
//   )
// })
