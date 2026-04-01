import { Controller } from "@hotwired/stimulus"

// Switches between Peso/Altezza/Testa chart variants on the landing page.
//
// Usage:
//   <div data-controller="landing-chart">
//     <button data-landing-chart-target="pill" data-action="landing-chart#switch" data-index="0">Peso</button>
//     <div data-landing-chart-target="chart" class="">...</div>   <!-- visible by default -->
//     <div data-landing-chart-target="chart" class="hidden">...</div>
//   </div>
export default class extends Controller {
  static targets = ["pill", "chart"]

  connect() {
    this.index = 0
    this.updateActive()
  }

  switch(event) {
    const idx = parseInt(event.currentTarget.dataset.index, 10)
    if (idx === this.index) return
    this.index = idx
    this.updateActive()
  }

  updateActive() {
    this.pillTargets.forEach((pill, i) => {
      if (i === this.index) {
        pill.classList.add("ring-2", "ring-offset-1")
        pill.style.ringColor = "var(--color-shuby-blue-800)"
      } else {
        pill.classList.remove("ring-2", "ring-offset-1")
      }
    })

    this.chartTargets.forEach((chart, i) => {
      chart.classList.toggle("hidden", i !== this.index)
    })
  }
}
