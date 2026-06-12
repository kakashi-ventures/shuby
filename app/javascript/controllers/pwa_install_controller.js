import { Controller } from "@hotwired/stimulus"
import { activateFocusTrap, setBackgroundInert } from "src/focus_trap"
import { isStandalone, isIOS, getDeferredPrompt, clearDeferredPrompt } from "src/pwa"

// Drives the in-app "Installa l'app" surfaces (dashboard banner + settings
// row). One controller instance per surface; the shared install state lives
// in src/pwa.js.
//
// `install()` branches at tap time:
//   - Android/Chromium with a captured beforeinstallprompt → fire the native
//     install dialog.
//   - iOS Safari / non-Chromium desktop → open a bottom-sheet with manual
//     "Aggiungi a Home" instructions.
//
// The bottom-sheet open/close/Escape/scroll-lock/swipe block is copied from
// bottom_sheet_controller.js (NOT inherited — see
// .claude/rules/bottom-sheet-overlays.md). The banner reveals only when the
// app is genuinely installable and hasn't been dismissed/installed.
//
// Pairs with .shuby-bottom-sheet-* (bottom-sheet.css) and
// .shuby-pwa-install-* (pwa-install.css).
export default class extends Controller {
  static targets = ["banner", "overlay", "sheet", "iosSteps", "genericSteps"]
  static classes = ["open"]
  static values = { cooldownDays: { type: Number, default: 14 } }

  static DISMISSED_KEY = "shuby.pwaInstallDismissedAt"
  static INSTALLED_KEY = "shuby.pwaInstalled"

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    this.onInstallable = this.onInstallable.bind(this)
    this.onInstalled = this.onInstalled.bind(this)
    this.onTouchStart = this.onTouchStart.bind(this)
    this.onTouchMove = this.onTouchMove.bind(this)
    this.onTouchEnd = this.onTouchEnd.bind(this)

    window.addEventListener("shuby:pwa-installable", this.onInstallable)
    window.addEventListener("shuby:pwa-installed", this.onInstalled)

    if (this.hasSheetTarget) {
      this.sheetTarget.addEventListener("touchstart", this.onTouchStart, { passive: true })
      this.sheetTarget.addEventListener("touchmove", this.onTouchMove, { passive: false })
      this.sheetTarget.addEventListener("touchend", this.onTouchEnd)
    }

    this.maybeRevealBanner()
  }

  disconnect() {
    window.removeEventListener("shuby:pwa-installable", this.onInstallable)
    window.removeEventListener("shuby:pwa-installed", this.onInstalled)

    if (this.hasSheetTarget) {
      this.sheetTarget.removeEventListener("touchstart", this.onTouchStart)
      this.sheetTarget.removeEventListener("touchmove", this.onTouchMove)
      this.sheetTarget.removeEventListener("touchend", this.onTouchEnd)
    }
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
  }

  // ── Install flow ─────────────────────────────────────────────────────────

  install(event) {
    event?.preventDefault?.()
    const deferred = getDeferredPrompt()

    if (deferred) {
      deferred.prompt()
      deferred.userChoice
        .then(({ outcome }) => {
          if (outcome === "accepted") this.hideBanner()
        })
        .finally(() => clearDeferredPrompt())
    } else {
      this.openSheet()
    }
  }

  dismiss(event) {
    event?.preventDefault?.()
    this.hideBanner()
    try {
      localStorage.setItem(this.constructor.DISMISSED_KEY, String(Date.now()))
    } catch (e) {
      // private mode — non-fatal, banner just won't stay dismissed
    }
  }

  // Reveal the banner only when it makes sense: not installed, not standalone,
  // not recently dismissed, and either installable now (Android prompt
  // captured) or on iOS (where manual instructions are the only path).
  maybeRevealBanner() {
    if (!this.hasBannerTarget) return
    if (isStandalone() || this.installed || this.dismissedRecently) return
    if (getDeferredPrompt() || isIOS()) this.showBanner()
  }

  onInstallable() {
    // The prompt can arrive after connect(); re-evaluate the banner.
    this.maybeRevealBanner()
  }

  onInstalled() {
    this.hideBanner()
  }

  showBanner() {
    if (this.hasBannerTarget) this.bannerTarget.hidden = false
  }

  hideBanner() {
    if (this.hasBannerTarget) this.bannerTarget.hidden = true
  }

  get installed() {
    try {
      return localStorage.getItem(this.constructor.INSTALLED_KEY) === "1"
    } catch (e) {
      return false
    }
  }

  get dismissedRecently() {
    try {
      const raw = localStorage.getItem(this.constructor.DISMISSED_KEY)
      const ts = raw ? parseInt(raw, 10) : 0
      if (!ts) return false
      const window = this.cooldownDaysValue * 24 * 60 * 60 * 1000
      return Date.now() - ts < window
    } catch (e) {
      return false
    }
  }

  // ── Bottom sheet (instructions) ──────────────────────────────────────────

  openSheet(event) {
    event?.preventDefault?.()
    if (!this.hasOverlayTarget) return

    // Show the step list matching the current platform.
    if (this.hasIosStepsTarget) this.iosStepsTarget.hidden = !isIOS()
    if (this.hasGenericStepsTarget) this.genericStepsTarget.hidden = isIOS()

    this.overlayTarget.classList.add(this.openClass)
    this.overlayTarget.setAttribute("aria-hidden", "false")
    document.body.classList.add("shuby-bottom-sheet-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
    const sheet = this.hasSheetTarget ? this.sheetTarget : this.overlayTarget
    this._releaseFocusTrap = activateFocusTrap(sheet)
    this._releaseInert = setBackgroundInert(this.overlayTarget)
  }

  closeSheet() {
    if (!this.hasOverlayTarget) return
    this.overlayTarget.classList.remove(this.openClass)
    this.overlayTarget.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-bottom-sheet-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
    this._releaseInert?.()
    this._releaseInert = null
    this._releaseFocusTrap?.()
    this._releaseFocusTrap = null
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) this.closeSheet()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.closeSheet()
  }

  // ── Swipe-to-dismiss (copied from bottom_sheet_controller.js) ─────────────

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
        this.closeSheet()
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
