import { Controller } from "@hotwired/stimulus"

const CONVERSION = {
  // Form input units -> imperial scalar; value * scalar = imperial display.
  // Weight is kg (DEC-022); the rest are SI base units (cm, grams).
  height: 1 / 2.54,              // cm -> in
  head_circumference: 1 / 2.54,  // cm -> in
  weight: 1000 / 453.59237,      // kg -> lb (DEC-022: form holds kg, not g)
  feeding_weight: 1 / 28.3495    // g -> oz
}

export default class extends Controller {
  static targets = [
    "valueInput", "valueLabel", "valueField",
    "unitToggle",
    "photoPreview", "photoPlaceholder", "removePhoto", "removePhotoField"
  ]
  static values = {
    placeholders: { type: Object, default: {} },
    titles: { type: Object, default: {} },
    metricUnits: { type: Object, default: {} },
    imperialUnits: { type: Object, default: {} },
    preferredUnit: { type: String, default: "metric" },
    persistUrl: { type: String, default: "" }
  }

  connect() {
    this.onBeforeSubmit = this.onBeforeSubmit.bind(this)
    this.element.addEventListener("submit", this.onBeforeSubmit)
    // Honor the user's saved measurement_unit preference on load.
    // If the field has a prefilled SI value (edit case), convert it to imperial.
    if (this.preferredUnitValue === "imperial") {
      this.applyUnit("imperial", { convertCurrentValue: true })
    }
  }

  disconnect() {
    this.element.removeEventListener("submit", this.onBeforeSubmit)
  }

  typeChanged(event) {
    const selectedType = event.target.value
    this.updateActiveTab(event.target)
    this.updatePlaceholder(selectedType)
    this.updateLabel(selectedType)
    this.updateOverlayTitle(selectedType)
    this.resetUnitToggle(selectedType)
  }

  // When the unit toggle is on "imperial", the visible input holds imperial.
  // Convert back to SI before the form is serialized so the server always
  // receives canonical units (g for weight, cm for height).
  onBeforeSubmit() {
    if (!this.hasUnitToggleTarget || !this.hasValueInputTarget) return
    const isImperial = this.unitToggleTarget.getAttribute("data-active") === "right"
    if (!isImperial) return
    const scalar = CONVERSION[this.currentType()]
    if (!scalar) return
    const display = parseFloat(this.valueInputTarget.value)
    if (Number.isNaN(display)) return
    this.valueInputTarget.value = this.round(display / scalar)
  }

  resetUnitToggle(newType) {
    if (!this.hasUnitToggleTarget) return
    // Reset the toggle to metric and refresh its labels to match the new type.
    const toggle = this.unitToggleTarget
    toggle.setAttribute("data-active", "left")
    toggle.querySelectorAll(".shuby-unit-toggle-option").forEach(opt => {
      const unitKind = opt.getAttribute("data-unit")
      opt.classList.toggle("active", unitKind === "metric")
      const label = unitKind === "metric"
        ? this.metricUnitsValue[newType]
        : this.imperialUnitsValue[newType]
      if (label) opt.textContent = label
    })
  }

  updateActiveTab(radio) {
    this.element.querySelectorAll(".shuby-tab-segmented-item")
      .forEach(label => label.classList.remove("active"))
    radio.closest(".shuby-tab-segmented-item")?.classList.add("active")
  }

  updatePlaceholder(type) {
    if (this.hasValueInputTarget && this.placeholdersValue[type]) {
      this.valueInputTarget.placeholder = this.placeholdersValue[type]
    }
  }

  updateLabel(type) {
    if (this.hasValueLabelTarget && this.titlesValue[type]) {
      this.valueLabelTarget.textContent = this.titlesValue[type].toUpperCase()
    }
  }

  updateOverlayTitle(type) {
    const title = document.getElementById("measurement_overlay_title")
    if (title && this.titlesValue[type]) {
      title.textContent = this.titlesValue[type]
    }
  }

  toggleUnit(event) {
    event.preventDefault()
    if (!this.hasUnitToggleTarget) return
    const currentSide = this.unitToggleTarget.getAttribute("data-active")
    const nextUnit = currentSide === "right" ? "metric" : "imperial"
    this.applyUnit(nextUnit, { convertCurrentValue: true })
    this.persistUnitPreference(nextUnit)
  }

  // Sets the toggle DOM state to the given unit and (optionally) converts the
  // current visible value to match. Extracted so connect() can reuse it to
  // honor User#measurement_unit on page load.
  applyUnit(unit, { convertCurrentValue = false } = {}) {
    if (!this.hasUnitToggleTarget) return
    const toggle = this.unitToggleTarget
    toggle.setAttribute("data-active", unit === "imperial" ? "right" : "left")
    toggle.querySelectorAll(".shuby-unit-toggle-option").forEach(opt => {
      opt.classList.toggle("active", opt.getAttribute("data-unit") === unit)
    })

    if (!convertCurrentValue) return
    if (!this.hasValueInputTarget) return
    const scalar = CONVERSION[this.currentType()]
    if (!scalar) return
    const current = parseFloat(this.valueInputTarget.value)
    if (Number.isNaN(current)) return

    // Stored SI value times scalar → imperial display; dividing goes back.
    const converted = unit === "imperial" ? current * scalar : current / scalar
    this.valueInputTarget.value = this.round(converted)
  }

  // Fire-and-forget PATCH so the user's saved preference stays in sync with
  // the inline toggle. The UI already reflects the change locally, so a
  // network failure here isn't user-facing.
  async persistUnitPreference(unit) {
    if (!this.persistUrlValue) return
    try {
      await fetch(this.persistUrlValue, {
        method: "PATCH",
        credentials: "same-origin",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]')?.content
        },
        body: JSON.stringify({ user: { measurement_unit: unit } })
      })
    } catch (_e) {
      // Best-effort sync; settings page remains the authoritative control.
    }
  }

  currentType() {
    const checked = this.element.querySelector('input[name="measurement[measurement_type]"]:checked')
    if (checked) return checked.value
    const hidden = this.element.querySelector('input[type="hidden"][name="measurement[measurement_type]"]')
    return hidden?.value ?? "weight"
  }

  round(n) {
    return Math.round(n * 100) / 100
  }

  photoChanged(event) {
    const file = event.target.files?.[0]
    if (!file) return

    if (this.hasRemovePhotoFieldTarget) {
      this.removePhotoFieldTarget.value = "0"
    }

    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPhotoPreviewTarget) {
        this.photoPreviewTarget.src = e.target.result
        this.photoPreviewTarget.classList.remove("hidden")
      }
      if (this.hasPhotoPlaceholderTarget) {
        this.photoPlaceholderTarget.classList.add("hidden")
      }
      if (this.hasRemovePhotoTarget) {
        this.removePhotoTarget.classList.remove("hidden")
      }
    }
    reader.readAsDataURL(file)
  }

  removePhoto(event) {
    event.preventDefault()
    if (this.hasRemovePhotoFieldTarget) {
      this.removePhotoFieldTarget.value = "1"
    }
    if (this.hasPhotoPreviewTarget) {
      this.photoPreviewTarget.src = ""
      this.photoPreviewTarget.classList.add("hidden")
    }
    if (this.hasPhotoPlaceholderTarget) {
      this.photoPlaceholderTarget.classList.remove("hidden")
    }
    if (this.hasRemovePhotoTarget) {
      this.removePhotoTarget.classList.add("hidden")
    }
    this.element.querySelector('input[type="file"][name$="[photo]"]').value = ""
  }
}
