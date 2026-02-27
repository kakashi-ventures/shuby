import { Controller } from "@hotwired/stimulus"

// Syncs a row of dot indicators with horizontal scroll position.
// Active dot becomes an elongated bar; inactive dots are small circles.
export default class extends Controller {
  static targets = ["scroller", "stepper"]

  connect() {
    this.buildDots()
    this.handleScroll = this.updateActiveDot.bind(this)
    this.scrollerTarget.addEventListener("scroll", this.handleScroll, { passive: true })
  }

  disconnect() {
    this.scrollerTarget.removeEventListener("scroll", this.handleScroll)
  }

  buildDots() {
    const count = this.scrollerTarget.children.length
    this.stepperTarget.replaceChildren()
    this.dots = []

    for (let i = 0; i < count; i++) {
      const dot = document.createElement("span")
      dot.classList.add("shuby-carousel-dot")
      if (i === 0) dot.classList.add("shuby-carousel-dot-active")
      this.stepperTarget.appendChild(dot)
      this.dots.push(dot)
    }
  }

  updateActiveDot() {
    const scroller = this.scrollerTarget
    const children = scroller.children
    if (children.length === 0) return

    const cardWidth = children[0].offsetWidth
    const gap = parseInt(getComputedStyle(scroller).gap) || 0
    const step = cardWidth + gap
    const index = Math.round(scroller.scrollLeft / step)
    const clamped = Math.min(Math.max(index, 0), children.length - 1)

    this.dots.forEach((dot, i) => {
      dot.classList.toggle("shuby-carousel-dot-active", i === clamped)
    })
  }
}
