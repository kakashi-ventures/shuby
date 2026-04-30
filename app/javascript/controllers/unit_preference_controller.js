import { Controller } from "@hotwired/stimulus"

// Cm/in (and gr/lb) toggle for measurement detail pages. Figma 621:10357.
//
// Optimizes for the heavy-use mobile flow: flipping the toggle updates the
// page in-place — value card, history rows, and chart all re-format from
// raw SI values they already hold. The pref persists to the server via a
// fire-and-forget PATCH so future renders match, but the UI never waits
// on the network. No page navigation, no Turbo morph, no flicker.
//
// Wiring contract:
//   - This element carries data-active="left|right" + a slider visual.
//     Click flips data-active and toggles `.active` on each option label.
//   - Dispatches `shuby:unit-changed` with `{ unitSystem }` to all
//     unit-display controllers on the page.
//   - Updates the chart wrapper's `data-growth-chart-unit-system-value`,
//     which fires Stimulus's value-changed callback and re-renders Chart.js.
export default class extends Controller {
  static values = {
    url: String
  }

  toggle() {
    const current = this.element.getAttribute("data-active") === "left" ? "metric" : "imperial"
    const next = current === "metric" ? "imperial" : "metric"

    this.applyVisualState(next)
    this.notifyUnitDisplays(next)
    this.notifyChart(next)
    this.persistPreference(next)
  }

  applyVisualState(next) {
    this.element.setAttribute("data-active", next === "imperial" ? "right" : "left")
    this.element.querySelectorAll(".shuby-unit-toggle-option").forEach(option => {
      option.classList.toggle("active", option.dataset.unit === next)
    })
  }

  notifyUnitDisplays(next) {
    window.dispatchEvent(new CustomEvent("shuby:unit-changed", {
      detail: { unitSystem: next }
    }))
  }

  notifyChart(next) {
    document.querySelectorAll('[data-controller~="growth-chart"]').forEach(chart => {
      chart.setAttribute("data-growth-chart-unit-system-value", next)
    })
  }

  // PATCH the user's pref so navigations to other pages render in the new unit.
  // Fire-and-forget: errors are swallowed so a flaky network never blocks the
  // already-applied UI flip. The user can re-toggle if the persistence missed.
  persistPreference(next) {
    const token = document.querySelector("meta[name=csrf-token]")?.content
    fetch(this.urlValue, {
      method: "PATCH",
      credentials: "same-origin",
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "X-CSRF-Token": token || ""
      },
      body: JSON.stringify({ user: { measurement_unit: next } })
    }).catch(() => {})
  }
}
