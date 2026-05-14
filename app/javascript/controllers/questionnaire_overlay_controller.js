import { Controller } from "@hotwired/stimulus"
import { activateFocusTrap, setBackgroundInert } from "src/focus_trap"

// Full-screen takeover overlay for the tappa (milestone) questionnaire.
// Rendered by `questionnaire_sessions/_overlay` on caller pages
// (Dashboard, Tappe timeline, stage detail).
//
// Flow:
//   1. User taps a trigger link (card / "Inizia" button). `openWithFrame`
//      intercepts the click, animates the overlay in, and sets the inner
//      Turbo Frame `src` to the link's href — the server responds with
//      the frame-scoped `overlay_frame` view (via a redirect from `start`
//      when needed). The skeleton placeholder shows while that resolves.
//   2. Inside the overlay, `questionnaire_stories_controller` drives the
//      slide flow and POSTs each answer via AJAX. Progress persists
//      server-side after every answer, so close is non-destructive.
//   3. Close fires via the X button, backdrop click, Escape key, or a
//      custom `questionnaire-overlay:close` event from the inner
//      controller (tapping the inner exit button).
export default class extends Controller {
  static targets = ["overlay", "frame", "skeletonTemplate"]
  static classes = ["open"]

  connect() {
    this.sessionCompletedDuringOpen = false
    this.onKeydown = this.onKeydown.bind(this)
    this.onCloseEvent = this.onCloseEvent.bind(this)
    this.onSlideChanged = this.onSlideChanged.bind(this)
    this.onSessionCompleted = this.onSessionCompleted.bind(this)
    window.addEventListener("questionnaire-overlay:close", this.onCloseEvent)
    window.addEventListener("questionnaire-overlay:slide-changed", this.onSlideChanged)
    window.addEventListener("questionnaire-overlay:session-completed", this.onSessionCompleted)
  }

  disconnect() {
    document.removeEventListener("keydown", this.onKeydown)
    window.removeEventListener("questionnaire-overlay:close", this.onCloseEvent)
    window.removeEventListener("questionnaire-overlay:slide-changed", this.onSlideChanged)
    window.removeEventListener("questionnaire-overlay:session-completed", this.onSessionCompleted)
    document.body.classList.remove("shuby-questionnaire-overlay-scroll-lock")
  }

  // Intercept a click on an entry-point link. Opens the overlay
  // optimistically (before the network resolves) so the animation starts
  // immediately and the user sees the skeleton while the Rails response
  // lands. Also prevents the Ruby Native auto_route from pushing the
  // href as a full native navigation.
  openWithFrame(event) {
    const link = event.currentTarget
    const url = link?.getAttribute("href")
    if (!url || !this.hasFrameTarget) return
    event.preventDefault()

    this.open()
    this.frameTarget.setAttribute("src", url)
  }

  open() {
    // Reset per-open flag — opening to view an already-completed session
    // shouldn't trigger a refresh on close.
    this.sessionCompletedDuringOpen = false
    this.overlayElement.classList.add(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "false")
    document.body.classList.add("shuby-questionnaire-overlay-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
    this._releaseFocusTrap = activateFocusTrap(this.overlayElement)
    this._releaseInert = setBackgroundInert(this.overlayElement)
  }

  close() {
    this.overlayElement.classList.remove(this.openClass)
    // Reset dark-teal completion variant so a re-open starts on the
    // verde-300 intro background.
    this.overlayElement.classList.remove("shuby-questionnaire-overlay--on-completion")
    this.overlayElement.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-questionnaire-overlay-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
    this._releaseInert?.()
    this._releaseInert = null
    this._releaseFocusTrap?.()
    this._releaseFocusTrap = null
    if (this.hasFrameTarget) {
      // Restore the skeleton so the next open shows it again. Turbo
      // keeps the previous response cached until a new src is set;
      // replacing children + removing src forces a clean reload.
      this.frameTarget.replaceChildren(...this.skeletonTemplate())
      this.frameTarget.removeAttribute("src")
    }

    // Refresh the caller page if the user just completed the session in
    // this overlay open, so the dashboard milestone box rotates to the
    // next area (or flips to all-complete) and the development_stages
    // history list picks up the new session.
    if (this.sessionCompletedDuringOpen) {
      this.sessionCompletedDuringOpen = false
      window.Turbo.visit(window.location.href, {action: "replace"})
    }
  }

  onSessionCompleted() {
    this.sessionCompletedDuringOpen = true
  }

  closeOnBackdrop(event) {
    if (event.target === event.currentTarget) this.close()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }

  onCloseEvent() {
    this.close()
  }

  // Swap the overlay's background between verde-300 (intro/question) and
  // verde-scuro-500 (completion) based on the inner slide controller's
  // current slide. Close button color follows via CSS.
  onSlideChanged(event) {
    const isCompletion = event.detail?.isCompletion === true
    this.overlayElement.classList.toggle(
      "shuby-questionnaire-overlay--on-completion",
      isCompletion
    )
  }

  skeletonTemplate() {
    if (!this.hasSkeletonTemplateTarget) return []
    const fragment = this.skeletonTemplateTarget.content.cloneNode(true)
    return Array.from(fragment.childNodes)
  }

  get overlayElement() {
    return this.hasOverlayTarget ? this.overlayTarget : this.element
  }
}
