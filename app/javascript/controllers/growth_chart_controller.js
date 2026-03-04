import { Controller } from "@hotwired/stimulus"
import { Chart, LineController, LineElement, PointElement, LinearScale, Filler, Tooltip, Legend } from "chart.js"

// Register only the components we need (tree-shakeable)
Chart.register(LineController, LineElement, PointElement, LinearScale, Filler, Tooltip, Legend)

// Dataset indices for fill targeting
// Order: P3(0), P10(1), P25(2), P75(3), P90(4), P97(5), P50(6), Child(7)
const DS_P3 = 0, DS_P10 = 1, DS_P25 = 2, DS_P75 = 3, DS_P90 = 4
const DS_CHILD = 7

export default class extends Controller {
  static targets = ["canvas", "zoomButton"]
  static values = {
    measurements: { type: Array, default: [] },
    whoCurves: { type: Array, default: [] },
    type: { type: String, default: "weight" },
    unit: { type: String, default: "kg" },
    title: { type: String, default: "" },
    zoom: { type: String, default: "all" }
  }

  // Shuby design tokens
  static COLORS = {
    childLine: "#0159B5",       // shuby-blue-800
    childPoint: "#0159B5",
    p50Line: "#2C9A94",         // shuby-verde-500
    normalBand: "rgba(44, 154, 148, 0.12)",   // verde, light
    warningBand: "rgba(243, 156, 18, 0.10)",  // orange, light
    alertBand: "rgba(231, 76, 60, 0.08)",     // red, light
    gridLine: "#E2E5E8",        // shuby-gray-500
    textColor: "#B5B7BA"        // shuby-gray-600
  }

  connect() {
    this.renderChart()
  }

  disconnect() {
    this.destroyChart()
  }

  zoomValueChanged() {
    this.renderChart()
  }

  setZoom(event) {
    const zoom = event.currentTarget.dataset.zoom
    this.zoomValue = zoom

    // Update active button styling
    this.zoomButtonTargets.forEach(btn => {
      btn.classList.toggle("active", btn.dataset.zoom === zoom)
    })
  }

  // For future PDF export
  exportImage() {
    return this.canvasTarget.toDataURL("image/png")
  }

  // --- Private ---

  renderChart() {
    this.destroyChart()

    const { curves, measurements, xRange } = this.prepareData()
    if (curves.length === 0) return

    const ctx = this.canvasTarget.getContext("2d")
    const C = this.constructor.COLORS

    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        datasets: [
          // 0: P3 boundary (invisible base line)
          this.percentileLine("P3", curves, "p3"),
          // 1: P10 — fill down to P3 (alert band)
          this.percentileLine("P10", curves, "p10", { fill: { target: DS_P3, above: C.alertBand } }),
          // 2: P25 — fill down to P10 (warning band)
          this.percentileLine("P25", curves, "p25", { fill: { target: DS_P10, above: C.warningBand } }),
          // 3: P75 — fill down to P25 (normal band)
          this.percentileLine("P75", curves, "p75", { fill: { target: DS_P25, above: C.normalBand } }),
          // 4: P90 — fill down to P75 (warning band)
          this.percentileLine("P90", curves, "p90", { fill: { target: DS_P75, above: C.warningBand } }),
          // 5: P97 — fill down to P90 (alert band)
          this.percentileLine("P97", curves, "p97", { fill: { target: DS_P90, above: C.alertBand } }),
          // 6: P50 median (visible dashed line)
          {
            label: "P50",
            data: curves.map(c => ({ x: c.month, y: c.p50 })),
            borderColor: C.p50Line,
            borderWidth: 1.5,
            borderDash: [4, 4],
            pointRadius: 0,
            fill: false,
            order: 1
          },
          // 7: Child's actual measurements
          {
            label: this.titleValue,
            data: measurements,
            borderColor: C.childLine,
            backgroundColor: C.childPoint,
            borderWidth: 2.5,
            pointRadius: 5,
            pointHoverRadius: 7,
            pointBackgroundColor: C.childPoint,
            pointBorderColor: "#FFFFFF",
            pointBorderWidth: 2,
            fill: false,
            spanGaps: true,
            order: 0
          }
        ]
      },
      options: this.chartOptions(xRange)
    })
  }

  destroyChart() {
    if (this.chart) {
      this.chart.destroy()
      this.chart = null
    }
  }

  percentileLine(label, curves, key, opts = {}) {
    return {
      label,
      data: curves.map(c => ({ x: c.month, y: c[key] })),
      borderColor: "transparent",
      backgroundColor: "transparent",
      pointRadius: 0,
      borderWidth: 0,
      fill: false,
      order: 5,
      ...opts
    }
  }

  prepareData() {
    const { curves, xRange } = this.filterCurves()
    if (curves.length === 0) return { curves: [], measurements: [], xRange: [0, 36] }

    // Measurements as {x, y} points at their exact fractional month age
    const measurements = this.measurementsValue.map(m => ({ x: m.age, y: m.value }))

    return { curves, measurements, xRange }
  }

  filterCurves() {
    const allCurves = this.whoCurvesValue
    if (!allCurves || allCurves.length === 0) return { curves: [], xRange: [0, 36] }

    const childAges = this.measurementsValue.map(m => m.age)
    const maxChildAge = childAges.length > 0 ? Math.max(...childAges) : 0

    // Floor/ceil boundaries to align with integer-month WHO data points.
    // Without this, fractional ages exclude boundary months (e.g., age 5.84
    // with "1m" zoom: 5.84-1=4.84 would exclude month 4).
    let min, max
    switch (this.zoomValue) {
      case "1m": min = Math.floor(maxChildAge - 1); max = Math.ceil(maxChildAge + 1); break
      case "3m": min = Math.floor(maxChildAge - 3); max = Math.ceil(maxChildAge + 1); break
      case "6m": min = Math.floor(maxChildAge - 6); max = Math.ceil(maxChildAge + 1); break
      default:   return { curves: allCurves, xRange: [0, 36] }
    }

    min = Math.max(min, 0)
    max = Math.min(max, 36)
    const curves = allCurves.filter(c => c.month >= min && c.month <= max)
    return { curves, xRange: [min, max] }
  }

  chartOptions(xRange) {
    const C = this.constructor.COLORS
    const [xMin, xMax] = xRange
    const span = xMax - xMin

    // Adapt tick spacing to zoom level
    let stepSize = 3
    if (span <= 3) stepSize = 1
    else if (span <= 8) stepSize = 1

    return {
      responsive: true,
      maintainAspectRatio: false,
      interaction: {
        mode: "nearest",
        intersect: false
      },
      plugins: {
        legend: { display: false },
        tooltip: {
          backgroundColor: "rgba(0, 0, 0, 0.8)",
          titleFont: { family: "Montserrat", size: 12 },
          bodyFont: { family: "Montserrat", size: 11 },
          padding: 10,
          cornerRadius: 8,
          filter: (item) => item.datasetIndex === DS_CHILD,
          callbacks: {
            title: (items) => {
              if (items.length === 0) return ""
              const months = items[0].parsed.x
              const wholeMonths = Math.floor(months)
              const days = Math.round((months - wholeMonths) * 30.44)
              if (days === 0) return `Mese ${wholeMonths}`
              return `${wholeMonths}m ${days}g`
            },
            label: (context) => {
              const value = context.parsed.y
              if (value === null) return null

              const age = context.parsed.x
              const measurement = this.measurementsValue.find(m =>
                Math.abs(m.age - age) < 0.01 && Math.abs(m.value - value) < 0.01
              )
              const lines = [`${value} ${this.unitValue}`]
              if (measurement && measurement.percentile != null) {
                lines.push(`${measurement.percentile}° percentile`)
              }
              if (measurement && measurement.date) {
                lines.push(measurement.date)
              }
              return lines
            }
          }
        }
      },
      scales: {
        x: {
          type: "linear",
          min: xMin,
          max: xMax,
          title: {
            display: true,
            text: "Mesi",
            font: { family: "Montserrat", size: 11 },
            color: C.textColor
          },
          ticks: {
            font: { family: "Montserrat", size: 10 },
            color: C.textColor,
            stepSize
          },
          grid: { color: C.gridLine }
        },
        y: {
          title: {
            display: true,
            text: this.unitValue,
            font: { family: "Montserrat", size: 11 },
            color: C.textColor
          },
          ticks: {
            font: { family: "Montserrat", size: 10 },
            color: C.textColor
          },
          grid: { color: C.gridLine }
        }
      }
    }
  }
}
