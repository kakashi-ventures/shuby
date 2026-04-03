import { Controller } from "@hotwired/stimulus"

// Touch micro-interactions for the landing page.
//
// Targets:
//   tiltable  — 3D tilt on press
//   pressable — scale-down on press
//   mascot    — wiggle + floating heart on tap
export default class extends Controller {
  static targets = ["tiltable", "pressable", "mascot"]

  connect() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
      return
    }

    this.tiltableTargets.forEach(el => {
      el.addEventListener("touchstart", this.handleTiltStart, { passive: true })
      el.addEventListener("touchend", this.handleTiltEnd, { passive: true })
    })

    this.pressableTargets.forEach(el => {
      el.addEventListener("touchstart", this.handlePressStart, { passive: true })
      el.addEventListener("touchend", this.handlePressEnd, { passive: true })
    })

    this.mascotTargets.forEach(el => {
      el.addEventListener("click", this.handleMascotTap)
    })
  }

  disconnect() {
    this.tiltableTargets.forEach(el => {
      el.removeEventListener("touchstart", this.handleTiltStart)
      el.removeEventListener("touchend", this.handleTiltEnd)
    })
    this.pressableTargets.forEach(el => {
      el.removeEventListener("touchstart", this.handlePressStart)
      el.removeEventListener("touchend", this.handlePressEnd)
    })
    this.mascotTargets.forEach(el => {
      el.removeEventListener("click", this.handleMascotTap)
    })
  }

  handleTiltStart = (e) => {
    e.currentTarget.classList.add("landing-tilt")
  }

  handleTiltEnd = (e) => {
    setTimeout(() => e.currentTarget.classList.remove("landing-tilt"), 200)
  }

  handlePressStart = (e) => {
    e.currentTarget.classList.add("landing-press")
  }

  handlePressEnd = (e) => {
    e.currentTarget.classList.remove("landing-press")
  }

  handleMascotTap = (e) => {
    const mascot = e.currentTarget

    // Wiggle
    mascot.classList.remove("landing-wiggle")
    void mascot.offsetHeight // force reflow
    mascot.classList.add("landing-wiggle")

    // Floating heart
    const heart = document.createElement("span")
    heart.textContent = "\u2764\uFE0F"
    heart.classList.add("landing-heart")
    heart.style.left = "50%"
    heart.style.top = "0"
    heart.style.fontSize = "1.25rem"
    mascot.style.position = "relative"
    mascot.appendChild(heart)
    setTimeout(() => heart.remove(), 800)
  }
}
