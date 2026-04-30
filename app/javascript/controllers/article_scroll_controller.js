import { Controller } from "@hotwired/stimulus"

// Handles the Figma scroll-overlap effect for article detail pages (Figma 05.02):
// - Full-width hero image at top, with a floating back button sitting on it
// - White content area slides up over the image on scroll
// - Title + inline chevron become a sticky compact header (Figma 510:23074)
// - Floating back fades out so the back affordance "repositions" into the
//   sticky bar per FA 6.2.1 (no double back buttons during scroll)
// - Scrolling back up restores the full layout
export default class extends Controller {
  static targets = ["hero", "stickyHeader", "floatingBack"]

  connect() {
    this.observer = new IntersectionObserver(
      ([entry]) => {
        const sticky = !entry.isIntersecting
        this.stickyHeaderTarget.classList.toggle("opacity-0", !sticky)
        this.stickyHeaderTarget.classList.toggle("-translate-y-full", !sticky)
        this.stickyHeaderTarget.classList.toggle("opacity-100", sticky)
        this.stickyHeaderTarget.classList.toggle("translate-y-0", sticky)
        if (this.hasFloatingBackTarget) {
          this.floatingBackTarget.classList.toggle("shuby-floating-back-hidden", sticky)
        }
      },
      { threshold: 0, rootMargin: "-56px 0px 0px 0px" }
    )
    this.observer.observe(this.heroTarget)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
