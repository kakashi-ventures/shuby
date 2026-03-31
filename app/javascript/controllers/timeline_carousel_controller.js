import { Controller } from "@hotwired/stimulus"

// Horizontal scrolling carousel for Timeline age band pills.
// Handles scroll centering, pill visual state toggling, and Turbo Frame content loading.
export default class extends Controller {
  static targets = ["scroller", "pill"]
  static values = {
    currentBandKey: String,
    contentUrl: String
  }

  connect() {
    // Use requestAnimationFrame to ensure layout is computed before scrolling
    requestAnimationFrame(() => this.scrollToCurrentBand())
  }

  scrollToCurrentBand() {
    const currentPill = this.pillTargets.find(
      pill => pill.dataset.bandKey === this.currentBandKeyValue
    )
    if (currentPill) {
      this.centerPill(currentPill, false)
    }
  }

  centerPill(pill, smooth = true) {
    const scroller = this.scrollerTarget
    const scrollLeft = pill.offsetLeft - (scroller.offsetWidth / 2) + (pill.offsetWidth / 2)
    scroller.scrollTo({ left: scrollLeft, behavior: smooth ? "smooth" : "instant" })
  }

  select(event) {
    const pill = event.currentTarget
    const bandKey = pill.dataset.bandKey

    // Update visual state on all pills
    this.pillTargets.forEach(p => this.updatePillState(p, bandKey))

    // Center the selected pill
    this.centerPill(pill)

    // Load new content via Turbo Frame
    const frame = document.getElementById("timeline-content")
    if (frame) {
      const url = new URL(this.contentUrlValue, window.location.origin)
      url.searchParams.set("band", bandKey)
      frame.src = url.toString()
    }
  }

  updatePillState(pill, selectedKey) {
    const bandKey = pill.dataset.bandKey
    const relationship = pill.dataset.bandRelationship

    // Remove all state classes
    pill.classList.remove("selected", "selected-primary", "selected-outline", "past")

    if (bandKey === selectedKey) {
      pill.classList.add("selected")
      pill.setAttribute("aria-selected", "true")
    } else {
      pill.setAttribute("aria-selected", "false")
      if (relationship === "past") {
        pill.classList.add("past")
      } else if (relationship === "current") {
        pill.classList.add("selected-primary")
      } else {
        pill.classList.add("selected-outline")
      }
    }
  }
}
