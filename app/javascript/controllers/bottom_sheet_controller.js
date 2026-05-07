import { Controller } from "@hotwired/stimulus"

// Generic bottom-sheet controller — open/close, Escape-to-close, body
// scroll-lock, swipe-to-dismiss, defensive backdrop-click handler.
//
// Identifier: `bottom-sheet`. Use directly on a host element:
//   <div data-controller="bottom-sheet"
//        data-bottom-sheet-open-class="shuby-bottom-sheet--open">
//     ...
//   </div>
// when no surface-specific behavior is needed (e.g. dashboard child
// selector). Surfaces that DO need extra behavior — Turbo-frame loads,
// skeleton restore, submit-end navigation — keep their own dedicated
// Stimulus controller and just reuse the same `.shuby-bottom-sheet-*`
// CSS classes (see measurement_overlay_controller.js for the form
// flow). Inheritance was tried and dropped; CSS extraction is what
// guarantees visual parity across surfaces, not a shared JS hierarchy.
//
// Pairs with .shuby-bottom-sheet-* in
// app/assets/tailwind/components/shuby/bottom-sheet.css.
export default class BottomSheetController extends Controller {
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
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
  }

  open(event) {
    event?.preventDefault?.()
    this.overlayElement.classList.add(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "false")
    document.body.classList.add("shuby-bottom-sheet-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.overlayElement.classList.remove(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
  }

  // Defensive backdrop-click handler. Use when the action target is the
  // backdrop element itself — guarantees the close fires only on backdrop
  // clicks, not on bubbled clicks from descendants.
  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) this.close()
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

    // Allow drag initiation from anywhere in the top 60px (handle + title).
    // Touches below that pass through if they start on a scrollable child
    // or a form input — otherwise they still drive the dismiss gesture.
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
