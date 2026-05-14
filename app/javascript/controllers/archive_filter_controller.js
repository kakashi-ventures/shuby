import { Controller } from "@hotwired/stimulus"

// Toggles the archive search/filter panel and handles debounced search submission.
export default class extends Controller {
  static targets = ["panel", "input", "form", "toggle"]

  connect() {
    this.debounceTimer = null
  }

  disconnect() {
    clearTimeout(this.debounceTimer)
  }

  toggle() {
    const isHidden = this.panelTarget.classList.contains("hidden")
    this.panelTarget.classList.toggle("hidden")
    this.#syncToggleExpanded(isHidden)

    if (isHidden) {
      this.inputTarget.focus()
    }
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.#syncToggleExpanded(false)
  }

  #syncToggleExpanded(expanded) {
    if (this.hasToggleTarget) this.toggleTarget.setAttribute("aria-expanded", expanded ? "true" : "false")
  }

  // Debounced search: submits the form after 300ms of inactivity
  search() {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, 300)
  }

  // Immediate submit (for type pill clicks)
  submit() {
    this.formTarget.requestSubmit()
  }
}
