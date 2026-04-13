import { Controller } from "@hotwired/stimulus"

// Handles the Figma scroll-overlap effect for article detail pages:
// - Full-width hero image at top
// - White content area slides up over the image on scroll
// - Title + bookmark become a sticky compact header
// - Scrolling back up restores the full layout
export default class extends Controller {
  static targets = ["hero", "stickyHeader"]

  connect() {
    this.observer = new IntersectionObserver(
      ([entry]) => {
        this.stickyHeaderTarget.classList.toggle("opacity-0", entry.isIntersecting)
        this.stickyHeaderTarget.classList.toggle("translate-y-[-100%]", entry.isIntersecting)
        this.stickyHeaderTarget.classList.toggle("opacity-100", !entry.isIntersecting)
        this.stickyHeaderTarget.classList.toggle("translate-y-0", !entry.isIntersecting)
      },
      { threshold: 0, rootMargin: "-56px 0px 0px 0px" }
    )
    this.observer.observe(this.heroTarget)
  }

  disconnect() {
    this.observer?.disconnect()
  }
}
