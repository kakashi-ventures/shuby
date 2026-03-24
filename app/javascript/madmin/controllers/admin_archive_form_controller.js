import { Controller } from "@hotwired/stimulus"

// Toggles visibility of content-type-specific field sections
// in the admin archive content form.
export default class extends Controller {
  static targets = ["tipFields", "activityFields"]

  connect() {
    this.toggle()
  }

  toggle() {
    const select = this.element.querySelector("[name*='content_type']")
    if (!select) return

    const value = select.value

    if (this.hasTipFieldsTarget) {
      this.tipFieldsTarget.style.display = (value === "tip") ? "" : "none"
    }
    if (this.hasActivityFieldsTarget) {
      this.activityFieldsTarget.style.display = (value === "activity") ? "" : "none"
    }
  }
}
