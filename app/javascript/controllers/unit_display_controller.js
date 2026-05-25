import { Controller } from "@hotwired/stimulus"

// Wraps a value+unit display element so it can re-format itself client-side
// when the user toggles measurement_unit on a detail page. The server emits
// the raw SI value (grams or cm); this controller converts + formats based
// on the active unit system, matching Measurement#formatted_value rules.
//
// Usage:
//   <span data-controller="unit-display"
//         data-unit-display-si-value-value="7000"
//         data-unit-display-type-value="weight"
//         data-unit-display-system-value="metric"
//         data-unit-display-format-value="value-unit">
//     3900 gr
//   </span>
//
// `format` is one of:
//   "value"       — number only ("15,43")
//   "unit"        — unit label only ("lb")
//   "value-unit"  — both, joined with a space ("15,43 lb")
//
// Listens for the global `shuby:unit-changed` event dispatched by
// unit_preference_controller after a toggle; updates systemValue and
// re-renders without a server round-trip.
export default class extends Controller {
  static values = {
    siValue: Number,
    type: String,
    system: { type: String, default: "metric" },
    format: { type: String, default: "value-unit" }
  }

  // Stored value is in grams (weight/feeding_weight) or centimeters (height/head).
  // factor is what to MULTIPLY the SI value by to get the display value.
  // Body weight metric divides grams by 1000 for kg display (DEC-022).
  static FACTORS = {
    weight: { metric: 1 / 1000, imperial: 1 / 453.59237 },
    feeding_weight: { metric: 1, imperial: 1 / 28.3495 },
    height: { metric: 1, imperial: 1 / 2.54 },
    head_circumference: { metric: 1, imperial: 1 / 2.54 }
  }

  static UNIT_LABELS = {
    weight: { metric: "kg", imperial: "lb" },
    feeding_weight: { metric: "gr", imperial: "oz" },
    height: { metric: "cm", imperial: "in" },
    head_circumference: { metric: "cm", imperial: "in" }
  }

  // Decimal places per type+system, mirroring Measurement::IMPERIAL[:decimals].
  // Metric weight shows 2 decimals max with trailing zeros dropped (4500g→"4,5";
  // 5000g→"5"); imperial weight 2 decimals (8.60).
  static DECIMALS = {
    weight: { metric: 2, imperial: 2 },
    feeding_weight: { metric: 0, imperial: 2 },
    height: { metric: 1, imperial: 1 },
    head_circumference: { metric: 1, imperial: 1 }
  }

  connect() {
    this.boundOnUnitChange = (e) => { this.systemValue = e.detail?.unitSystem || "metric" }
    window.addEventListener("shuby:unit-changed", this.boundOnUnitChange)
    this.render()
  }

  disconnect() {
    window.removeEventListener("shuby:unit-changed", this.boundOnUnitChange)
  }

  systemValueChanged() {
    this.render()
  }

  render() {
    const fmt = this.formatValue
    if (fmt === "unit") {
      this.element.textContent = this.unitLabel()
      return
    }
    const formatted = this.formattedValue()
    this.element.textContent = fmt === "value-unit"
      ? `${formatted} ${this.unitLabel()}`
      : formatted
  }

  formattedValue() {
    const factor = this.constructor.FACTORS[this.typeValue]?.[this.systemValue] ?? 1
    const decimals = this.constructor.DECIMALS[this.typeValue]?.[this.systemValue] ?? 1
    const converted = this.siValueValue * factor

    // Mirror Measurement#format_decimal: drop trailing zero decimals and
    // use Italian comma as the decimal separator.
    if (decimals === 0) return String(Math.round(converted))
    const rounded = Number(converted.toFixed(decimals))
    if (rounded === Math.trunc(rounded)) return String(Math.trunc(rounded))
    return rounded.toFixed(decimals).replace(".", ",")
  }

  unitLabel() {
    return this.constructor.UNIT_LABELS[this.typeValue]?.[this.systemValue] || ""
  }
}
