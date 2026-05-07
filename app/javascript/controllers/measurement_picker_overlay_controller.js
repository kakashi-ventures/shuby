import { Controller } from "@hotwired/stimulus"

// Type-picker bottom sheet for adding a measurement.
// Figma: 463:5785 (no data) / 463:5995 (with data) / 795:8492.
//
// Simpler than the form overlay — no turbo frame, no skeleton, no
// post-submit redirect. Just open / close, Escape, backdrop click.
// Picker cards close this overlay AND open the form overlay via a
// chained Stimulus `data-action` (see measurement_overlay_link_data
// helper with `close_picker: true`).
//
// Uses the shared `.shuby-bottom-sheet-*` CSS classes from
// `bottom-sheet.css` (chrome) and the `shuby-bottom-sheet--open`
// modifier (configured via `data-measurement-picker-overlay-open-class`
// on the host element). The behavior is duplicated rather than
// inherited from `BottomSheetController` because Stimulus's static
// metadata pickup across imported base classes is unreliable in this
// importmap setup; the CSS extraction is what guarantees visual
// parity, not a shared JS class hierarchy.
export default class extends Controller {
  static targets = ["overlay", "sheet"]
  static classes = ["open"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    this.onTouchStart = this.onTouchStart.bind(this)
    this.onTouchMove = this.onTouchMove.bind(this)
    this.onTouchEnd = this.onTouchEnd.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
    this._detachSwipe()
  }

  open() {
    this.overlayElement.classList.add(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "false")
    document.body.classList.add("shuby-bottom-sheet-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
    this._attachSwipe()
  }

  close() {
    this.overlayElement.classList.remove(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
    this._detachSwipe()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  get overlayElement() {
    return this.hasOverlayTarget ? this.overlayTarget : this.element
  }

  // ── Swipe-to-dismiss ────────────────────────────────────────────────────

  _attachSwipe() {
    if (!this.hasSheetTarget) return
    this.sheetTarget.addEventListener("touchstart", this.onTouchStart, { passive: true })
    this.sheetTarget.addEventListener("touchmove", this.onTouchMove, { passive: false })
    this.sheetTarget.addEventListener("touchend", this.onTouchEnd)
  }

  _detachSwipe() {
    if (!this.hasSheetTarget) return
    this.sheetTarget.removeEventListener("touchstart", this.onTouchStart)
    this.sheetTarget.removeEventListener("touchmove", this.onTouchMove)
    this.sheetTarget.removeEventListener("touchend", this.onTouchEnd)
  }

  onTouchStart(event) {
    const touch = event.touches[0]
    const sheet = this.sheetTarget
    const sheetTop = sheet.getBoundingClientRect().top
    const touchY = touch.clientY

    if (touchY - sheetTop > 60) {
      const scrollable = touch.target.closest("[data-swipe-scroll]") ||
        touch.target.closest("input, select, textarea")
      if (scrollable) {
        this._swipeCancelled = true
        return
      }
    }

    this._swipeCancelled = false
    this._swipeStartY = touchY
    this._swipeDelta = 0
    sheet.style.willChange = "transform"
    sheet.style.transition = "none"
  }

  onTouchMove(event) {
    if (this._swipeCancelled || this._swipeStartY == null) return
    const touch = event.touches[0]
    const delta = Math.max(0, touch.clientY - this._swipeStartY)
    this._swipeDelta = delta
    if (delta > 0) event.preventDefault()
    this.sheetTarget.style.transform = `translateY(${delta}px)`
  }

  onTouchEnd() {
    if (this._swipeCancelled || this._swipeStartY == null) return
    const sheet = this.sheetTarget
    const DISMISS_THRESHOLD = 80

    sheet.style.willChange = ""
    sheet.style.transition = ""

    if (this._swipeDelta >= DISMISS_THRESHOLD) {
      sheet.style.transition = "transform 0.25s ease-out"
      sheet.style.transform = "translateY(100%)"
      sheet.addEventListener("transitionend", () => {
        sheet.style.transform = ""
        sheet.style.transition = ""
        this.close()
      }, { once: true })
    } else {
      sheet.style.transition = "transform 0.2s ease-out"
      sheet.style.transform = ""
      sheet.addEventListener("transitionend", () => {
        sheet.style.transition = ""
      }, { once: true })
    }

    this._swipeStartY = null
    this._swipeDelta = 0
  }
}
