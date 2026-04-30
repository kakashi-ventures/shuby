import { Controller } from "@hotwired/stimulus"

// Type-picker bottom sheet for adding a measurement.
// Figma: 463:5785 (no data) / 463:5995 (with data) / 795:8492.
//
// Simpler than the form overlay — no turbo frame, no skeleton, no
// post-submit redirect. Just open / close, Escape, backdrop click.
// Picker cards close this overlay AND open the form overlay via a
// chained Stimulus `data-action` (see measurement_overlay_link_data
// helper with `close_picker: true`).
export default class extends Controller {
  static targets = ["overlay"]
  static classes = ["open"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("shuby-measurement-overlay-scroll-lock")
  }

  open() {
    this.overlayElement.classList.add(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "false")
    document.body.classList.add("shuby-measurement-overlay-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.overlayElement.classList.remove(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-measurement-overlay-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  get overlayElement() {
    return this.hasOverlayTarget ? this.overlayTarget : this.element
  }
}
