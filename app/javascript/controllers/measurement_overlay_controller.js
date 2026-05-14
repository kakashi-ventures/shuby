import { Controller } from "@hotwired/stimulus"
import { activateFocusTrap, setBackgroundInert } from "src/focus_trap"

// Measurement form bottom sheet. Figma: 621:9860 (Overlay_Aggiungi
// Altezza). Built on the shared `.shuby-bottom-sheet-*` CSS classes
// (see `bottom-sheet.css`) but the JS contract is standalone — Stimulus
// inheritance across importmap-loaded base classes is unreliable, so
// the open/close/swipe/scroll-lock behavior is duplicated here rather
// than imported from `BottomSheetController`.
export default class extends Controller {
  static targets = ["sheet", "frame", "overlay", "skeletonTemplate"]
  static classes = ["open"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    this.onFrameLoad = this.onFrameLoad.bind(this)
    this.onSubmitEnd = this.onSubmitEnd.bind(this)
    this.onTouchStart = this.onTouchStart.bind(this)
    this.onTouchMove = this.onTouchMove.bind(this)
    this.onTouchEnd = this.onTouchEnd.bind(this)

    if (this.hasFrameTarget) {
      this.frameTarget.addEventListener("turbo:frame-load", this.onFrameLoad)
      this.frameTarget.addEventListener("turbo:submit-end", this.onSubmitEnd)
    }

    if (this.hasSheetTarget) {
      this.sheetTarget.addEventListener("touchstart", this.onTouchStart, { passive: true })
      this.sheetTarget.addEventListener("touchmove", this.onTouchMove, { passive: false })
      this.sheetTarget.addEventListener("touchend", this.onTouchEnd)
    }
  }

  disconnect() {
    if (this.hasFrameTarget) {
      this.frameTarget.removeEventListener("turbo:frame-load", this.onFrameLoad)
      this.frameTarget.removeEventListener("turbo:submit-end", this.onSubmitEnd)
    }
    if (this.hasSheetTarget) {
      this.sheetTarget.removeEventListener("touchstart", this.onTouchStart)
      this.sheetTarget.removeEventListener("touchmove", this.onTouchMove)
      this.sheetTarget.removeEventListener("touchend", this.onTouchEnd)
    }
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
  }

  // Intercepts a click on a link targeting the overlay frame. Opens the
  // sheet optimistically (before the fetch resolves) so the animation
  // starts immediately and the user sees a skeleton while the Rails form
  // loads in. Also prevents the Ruby Native auto_route from pushing the
  // href as a full-page navigation.
  openWithFrame(event) {
    const link = event.currentTarget
    const url = link?.getAttribute("href")
    if (!url || !this.hasFrameTarget) return
    event.preventDefault()

    this.open()
    this.frameTarget.setAttribute("src", url)
  }

  open() {
    this.overlayElement.classList.add(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "false")
    document.body.classList.add("shuby-bottom-sheet-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
    const sheet = this.hasSheetTarget ? this.sheetTarget : this.overlayElement
    this._releaseFocusTrap = activateFocusTrap(sheet)
    this._releaseInert = setBackgroundInert(this.overlayElement)
  }

  close() {
    this.overlayElement.classList.remove(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
    this._releaseInert?.()
    this._releaseInert = null
    this._releaseFocusTrap?.()
    this._releaseFocusTrap = null
    if (this.hasFrameTarget) {
      // Restore the default skeleton so the next open shows it again
      // (Turbo keeps the previous response until a new src is set).
      this.frameTarget.replaceChildren(...this.skeletonTemplate())
      this.frameTarget.removeAttribute("src")
    }
  }

  skeletonTemplate() {
    if (!this.hasSkeletonTemplateTarget) return []
    const fragment = this.skeletonTemplateTarget.content.cloneNode(true)
    return Array.from(fragment.childNodes)
  }

  get overlayElement() {
    return this.hasOverlayTarget ? this.overlayTarget : this.element
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) this.close()
  }

  onFrameLoad() {
    // Sheet is already open — focus the first field now that the form
    // has been swapped in for the skeleton.
    this.focusFirstField()
  }

  onSubmitEnd(event) {
    if (!event.detail?.success) return
    this.close()
    const redirectUrl = event.detail.fetchResponse?.response?.url
    if (redirectUrl && window.Turbo?.visit) {
      // `advance` adds a history entry (so Back returns to the dashboard)
      // and scrolls the new page to top — `replace` preserves the caller's
      // scroll offset, which lands the user at the bottom of the new page.
      window.Turbo.visit(redirectUrl, { action: "advance" })
    } else if (window.Turbo?.visit) {
      window.Turbo.visit(window.location.href, { action: "replace" })
    } else {
      window.location.assign(redirectUrl || window.location.href)
    }
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  focusFirstField() {
    requestAnimationFrame(() => {
      const field = this.hasSheetTarget
        ? this.sheetTarget.querySelector("input:not([type=hidden]), select, textarea, button")
        : null
      field?.focus({ preventScroll: true })
    })
  }

  // ── Swipe-to-dismiss ────────────────────────────────────────────────────

  onTouchStart(event) {
    // Only track single-touch drags that start on the handle or near the top
    // of the sheet. Starting in the scrollable content area passes through.
    const touch = event.touches[0]
    const sheet = this.sheetTarget
    const sheetTop = sheet.getBoundingClientRect().top
    const touchY = touch.clientY

    // Allow drag initiation from anywhere in the top 60px (handle + title bar)
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
    // Prevent page scroll while dragging the sheet down
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
      // Animate fully off-screen then close
      sheet.style.transition = "transform 0.25s ease-out"
      sheet.style.transform = "translateY(100%)"
      sheet.addEventListener("transitionend", () => {
        sheet.style.transform = ""
        sheet.style.transition = ""
        this.close()
      }, { once: true })
    } else {
      // Snap back
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
