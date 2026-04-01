import { Controller } from "@hotwired/stimulus"

// Reveals elements with CSS animations when they scroll into view.
//
// Usage:
//   <div data-controller="scroll-reveal"
//        data-scroll-reveal-animation-value="landing-fade-up"
//        data-scroll-reveal-stagger-value="120"
//        data-scroll-reveal-threshold-value="0.15">
//     <div data-scroll-reveal-target="item">...</div>
//     <div data-scroll-reveal-target="item">...</div>
//   </div>
//
// If no targets are specified, the controller element itself is animated.
export default class extends Controller {
  static targets = ["item"]
  static values = {
    animation: { type: String, default: "landing-fade-up" },
    stagger: { type: Number, default: 0 },
    threshold: { type: Number, default: 0.15 },
    once: { type: Boolean, default: true }
  }

  connect() {
    // Respect reduced motion preference
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return
    }

    this.elements = this.hasItemTarget ? this.itemTargets : [this.element]
    this.elements.forEach(el => el.classList.add("landing-hidden"))

    this.observer = new IntersectionObserver(
      (entries) => this.handleIntersect(entries),
      { threshold: this.thresholdValue }
    )

    this.observer.observe(this.element)
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  handleIntersect(entries) {
    entries.forEach(entry => {
      if (!entry.isIntersecting) return

      this.elements.forEach((el, index) => {
        const delay = index * this.staggerValue
        el.style.animationDelay = `${delay}ms`
        el.classList.remove("landing-hidden")
        el.classList.add(this.animationValue)
      })

      if (this.onceValue) {
        this.observer.unobserve(entry.target)
      }
    })
  }
}
