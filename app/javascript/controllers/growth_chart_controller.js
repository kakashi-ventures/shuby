import { Controller } from "@hotwired/stimulus"
import { Chart, LineController, LineElement, PointElement, LinearScale, Filler, Tooltip, Legend } from "chart.js"

// Register only the components we need (tree-shakeable)
Chart.register(LineController, LineElement, PointElement, LinearScale, Filler, Tooltip, Legend)

// Dataset indices for fill targeting and tooltip routing.
// Order: P10(0), P90(1), P25(2), P75(3), P50(4), Child(5)
const DS_P10 = 0
const DS_P25 = 2
const DS_CHILD = 5

export default class extends Controller {
  static targets = ["canvas", "zoomButton"]
  static values = {
    measurements: { type: Array, default: [] },
    whoCurves: { type: Array, default: [] },
    type: { type: String, default: "weight" },
    unitSystem: { type: String, default: "metric" },
    title: { type: String, default: "" },
    zoom: { type: String, default: "all" }
  }

  // Figma 621:10252 — calmer, parent-friendly visual.
  // Three nested blue bands replace the previous green/orange/red 5-band scheme;
  // out-of-range signaling stays on the value card (percentile_color_class).
  static COLORS = {
    childLine: "#0159B5",       // shuby-blue-800
    childPoint: "#0159B5",
    p50Line: "#0159B5",         // shuby-blue-800 — solid (was dashed verde)
    bandOuter: "rgba(158, 198, 240, 0.25)", // shuby-blue-500 @ 25% — P10-P90
    bandInner: "rgba(158, 198, 240, 0.45)", // shuby-blue-500 @ 45% — P25-P75
    gridLine: "#E2E5E8",        // shuby-gray-500
    textColor: "#616467"        // shuby-gray-800
  }

  // Y-axis title prefix per measurement_type (Italian).
  // feeding_weight intentionally omitted — that type doesn't get a percentile chart.
  static TYPE_LABELS = {
    weight: "Peso",
    height: "Altezza",
    head_circumference: "Circonferenza cranica"
  }

  // Unit labels by type + system. Mirror of Measurement::IMPERIAL[:label] in JS.
  // These are physical-constant unit names — won't drift from Ruby.
  static UNIT_LABELS = {
    weight: { metric: "kg", imperial: "lb" },
    height: { metric: "cm", imperial: "in" },
    head_circumference: { metric: "cm", imperial: "in" }
  }

  // Multiplicative factor to convert metric chart values (kg / cm) to imperial.
  // Derived from Measurement::IMPERIAL scalars: kg → lb is 1000 / 453.59237;
  // cm → in is 1 / 2.54. Hardcoded as physical constants — no drift risk.
  static IMPERIAL_FACTORS = {
    weight: 2.20462262,
    height: 0.393700787,
    head_circumference: 0.393700787
  }

  connect() {
    // Defer chart creation to next animation frame so the canvas's container
    // has finished laying out — Chart.js's responsive sizing reads the parent's
    // clientWidth/clientHeight, which can still be 0 if measured synchronously
    // during a fresh page render.
    this.rafId = requestAnimationFrame(() => {
      this.rafId = null
      this.renderChart()
    })
  }

  disconnect() {
    if (this.rafId) {
      cancelAnimationFrame(this.rafId)
      this.rafId = null
    }
    this.destroyChart()
  }

  zoomValueChanged() {
    this.renderChart()
  }

  // Fires when Turbo morph swaps in updated data-attributes (e.g. user
  // flips the unit toggle on the detail page → server re-renders with
  // converted measurements + who curves + new unit label, morph
  // propagates them, Stimulus calls this). Triggering renderChart()
  // here picks up the new values atomically — measurementsValueChanged
  // and whoCurvesValueChanged are intentionally not defined to avoid
  // multiple redundant re-renders during the same morph cycle.
  unitSystemValueChanged() {
    if (this.chart) this.renderChart()
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
    // Belt-and-suspenders: kill any chart instance still bound to this canvas
    // in Chart.js's global registry. The wrapper carries `data-turbo-permanent`
    // (chart partial) so the canvas survives morph refreshes; if a stray
    // chart instance remained on it (e.g. from a previous controller cycle),
    // a second `new Chart()` would error out.
    const existing = Chart.getChart?.(this.canvasTarget)
    if (existing) existing.destroy()
    this.destroyChart()

    const { curves, measurements, xRange } = this.prepareData()
    if (curves.length === 0) return

    const ctx = this.canvasTarget.getContext("2d")
    const C = this.constructor.COLORS

    // Expose the chart instance on the canvas element so introspection
    // tools (system tests, devtools) can read the live config without
    // needing access to Chart.js's module-scoped registry.
    this.chart = new Chart(ctx, {
      type: "line",
      data: {
        datasets: [
          // 0: P10 invisible base — anchor for outer band fill
          this.percentileLine("P10", curves, "p10"),
          // 1: P90 — fill down to P10 with outer-band tint
          this.percentileLine("P90", curves, "p90", { fill: { target: DS_P10, above: C.bandOuter } }),
          // 2: P25 invisible base — anchor for inner band fill
          this.percentileLine("P25", curves, "p25"),
          // 3: P75 — fill down to P25 with inner-band tint
          this.percentileLine("P75", curves, "p75", { fill: { target: DS_P25, above: C.bandInner } }),
          // 4: P50 median — solid blu-800 line (no dash)
          {
            label: "P50",
            data: curves.map(c => ({ x: c.month, y: c.p50 })),
            borderColor: C.p50Line,
            borderWidth: 1.5,
            pointRadius: 0,
            fill: false,
            order: 1
          },
          // 5: Child's actual measurements
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
    this.canvasTarget.__shubyChart = this.chart
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
    const { curves: rawCurves, xRange } = this.filterCurves()
    if (rawCurves.length === 0) return { curves: [], measurements: [], xRange: [0, 36] }

    // Apply imperial conversion at render time so toggle flips don't need
    // a server round-trip. Metric mode uses the values verbatim.
    const factor = this.imperialFactor()
    const curves = factor === 1
      ? rawCurves
      : rawCurves.map(c => Object.fromEntries(
          Object.entries(c).map(([k, v]) => [k, k === "month" ? v : Number((v * factor).toFixed(4))])
        ))
    const measurements = this.measurementsValue.map(m => ({
      x: m.age,
      y: factor === 1 ? m.value : Number((m.value * factor).toFixed(2))
    }))

    return { curves, measurements, xRange }
  }

  imperialFactor() {
    if (this.unitSystemValue !== "imperial") return 1
    return this.constructor.IMPERIAL_FACTORS[this.typeValue] || 1
  }

  unitLabel() {
    const labels = this.constructor.UNIT_LABELS[this.typeValue]
    return labels ? labels[this.unitSystemValue] : ""
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
    const useWeeks = span <= 3

    // X-axis tick spacing:
    //   weeks mode → 0.25 month = 1 week
    //   months mode → at most ~8 ticks across the span
    const stepSize = useWeeks ? 0.25 : Math.max(1, Math.ceil(span / 8))
    const yTitle = `${this.constructor.TYPE_LABELS[this.typeValue] || this.titleValue} (${this.unitLabel()})`

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
              const lines = [`${value} ${this.unitLabel()}`]
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
            text: useWeeks ? "Età (settimane)" : "Età (mesi)",
            font: { family: "Montserrat", size: 11 },
            color: C.textColor
          },
          ticks: {
            font: { family: "Montserrat", size: 10 },
            color: C.textColor,
            stepSize,
            // 4.345 ≈ avg weeks per month — internal data stays in months,
            // only the tick label gets relabeled when in weeks mode.
            callback: useWeeks ? (v) => Math.round(v * 4.345) : (v) => v
          },
          grid: { color: C.gridLine, borderDash: [3, 3] }
        },
        y: {
          title: {
            display: true,
            text: yTitle,
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
