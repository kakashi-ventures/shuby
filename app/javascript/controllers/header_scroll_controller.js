import { Controller } from "@hotwired/stimulus"

// Controls header background color based on scroll position
// Transitions from blue to white when scrolling past a sentinel element
export default class extends Controller {
  static targets = ["header", "sentinel"]
  static classes = ["scrolled"]
  static values = {
    threshold: { type: Number, default: 0 }
  }

  connect() {
    this.setupIntersectionObserver()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupIntersectionObserver() {
    const options = {
      root: null,
      rootMargin: `${this.thresholdValue}px`,
      threshold: 0
    }

    this.observer = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        // When sentinel is NOT intersecting (scrolled past it), add scrolled class
        if (!entry.isIntersecting) {
          this.headerTarget.classList.add(...this.scrolledClasses)
        } else {
          this.headerTarget.classList.remove(...this.scrolledClasses)
        }
      })
    }, options)

    if (this.hasSentinelTarget) {
      this.observer.observe(this.sentinelTarget)
    }
  }
}
