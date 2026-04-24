import { Controller } from "@hotwired/stimulus"

// Minimal cm/in toggle for the measurement detail page (Figma 621:10357).
// Persists the flip to the user's global `measurement_unit` via a PATCH to
// `/settings/privacy`, then reloads the current page so the chart and the
// featured card re-render in the new unit. The measurement-form toggle has
// richer behavior (in-place input conversion + no reload); this controller is
// deliberately stripped down for read-only pages where only display matters.
export default class extends Controller {
  static values = {
    url: String
  }

  async toggle() {
    const current = this.element.getAttribute("data-active") === "left" ? "metric" : "imperial"
    const next = current === "metric" ? "imperial" : "metric"
    const token = document.querySelector("meta[name=csrf-token]")?.content

    try {
      await fetch(this.urlValue, {
        method: "PATCH",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": token || ""
        },
        body: JSON.stringify({ user: { measurement_unit: next } })
      })
    } catch (_) {
      // Network failure: no-op. The visual toggle reverts on reload.
    }

    if (window.Turbo?.visit) {
      window.Turbo.visit(window.location.href, { action: "replace" })
    } else {
      window.location.reload()
    }
  }
}
