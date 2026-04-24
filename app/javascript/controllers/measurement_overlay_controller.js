import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sheet", "frame", "overlay", "skeletonTemplate"]
  static classes = ["open"]

  connect() {
    this.onKeydown = this.onKeydown.bind(this)
    this.onFrameLoad = this.onFrameLoad.bind(this)
    this.onSubmitEnd = this.onSubmitEnd.bind(this)

    if (this.hasFrameTarget) {
      this.frameTarget.addEventListener("turbo:frame-load", this.onFrameLoad)
      this.frameTarget.addEventListener("turbo:submit-end", this.onSubmitEnd)
    }
  }

  disconnect() {
    if (this.hasFrameTarget) {
      this.frameTarget.removeEventListener("turbo:frame-load", this.onFrameLoad)
      this.frameTarget.removeEventListener("turbo:submit-end", this.onSubmitEnd)
    }
    document.removeEventListener("keydown", this.onKeydown)
    document.body.classList.remove("shuby-measurement-overlay-scroll-lock")
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
    document.body.classList.add("shuby-measurement-overlay-scroll-lock")
    document.addEventListener("keydown", this.onKeydown)
  }

  close() {
    this.overlayElement.classList.remove(this.openClass)
    this.overlayElement.setAttribute("aria-hidden", "true")
    document.body.classList.remove("shuby-measurement-overlay-scroll-lock")
    document.removeEventListener("keydown", this.onKeydown)
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
    // Sheet is already open — just focus the first field now that the form
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
}
