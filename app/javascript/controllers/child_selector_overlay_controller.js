import { Controller } from "@hotwired/stimulus"

// Bottom-sheet overlay for the dashboard child selector. Mirrors
// measurement_overlay_controller in shape (open/close + escape +
// backdrop + swipe-to-dismiss) but omits the turbo_frame logic —
// the overlay's content is server-rendered inline because the list
// of children is small and stable across opens. Selection POSTs hit
// /child_selections/:id which redirect_back's; Turbo Drive handles
// the navigation.
export default class extends Controller {
  static targets = ["overlay", "sheet"]
  static classes = ["open"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    this.onTouchStart = this.onTouchStart.bind(this)
    this.onTouchMove = this.onTouchMove.bind(this)
    this.onTouchEnd = this.onTouchEnd.bind(this)

    if (this.hasSheetTarget) {
      this.sheetTarget.addEventListener("touchstart", this.onTouchStart, { passive: true })
      this.sheetTarget.addEventListener("touchmove", this.onTouchMove, { passive: false })
      this.sheetTarget.addEventListener("touchend", this.onTouchEnd)
    }
  }

  disconnect() {
    if (this.hasSheetTarget) {
      this.sheetTarget.removeEventListener("touchstart", this.onTouchStart)
      this.sheetTarget.removeEventListener("touchmove", this.onTouchMove)
      this.sheetTarget.removeEventListener("touchend", this.onTouchEnd)
    }
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("shuby-child-selector-overlay-scroll-lock")
  }

  open(event) {
    event?.preventDefault?.()
    this.overlayElement.classList.add(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "false")
    document.body.classList.add("shuby-child-selector-overlay-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.overlayElement.classList.remove(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-child-selector-overlay-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
  }

  get overlayElement() {
    return this.hasOverlayTarget ? this.overlayTarget : this.element
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  // ── Swipe-to-dismiss ────────────────────────────────────────────────────

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
      sheet.style.transform = `translateY(100%)`
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
