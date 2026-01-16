import { Controller } from "@hotwired/stimulus"

// Handles conditional visibility of form fields based on other field values
export default class extends Controller {
  static targets = [
    "trigger",
    "conditional",
    "gestationalTrigger",
    "prematureModule",
    "feedingTrigger",
    "feedingDetails",
    "hereditaryTrigger",
    "hereditaryDetails"
  ]

  connect() {
    // Initialize visibility on page load
    this.initializeVisibility()
  }

  initializeVisibility() {
    // Family structure conditional
    if (this.hasTriggerTarget && this.hasConditionalTarget) {
      this.toggle()
    }

    // Premature module
    if (this.hasGestationalTriggerTarget && this.hasPrematureModuleTarget) {
      this.togglePremature()
    }

    // Feeding details
    if (this.hasFeedingTriggerTarget && this.hasFeedingDetailsTarget) {
      this.toggleFeeding()
    }

    // Hereditary conditions
    if (this.hasHereditaryTriggerTarget && this.hasHereditaryDetailsTarget) {
      this.toggleHereditary()
    }
  }

  // Toggle two_parents_type visibility based on family_structure
  toggle() {
    const value = this.triggerTarget.value
    const showValue = this.conditionalTarget.dataset.showWhen

    if (value === showValue) {
      this.conditionalTarget.classList.remove("hidden")
    } else {
      this.conditionalTarget.classList.add("hidden")
    }
  }

  // Toggle premature module visibility based on gestational age
  togglePremature() {
    const value = this.gestationalTriggerTarget.value
    const prematureValues = ["very_preterm", "moderate_preterm", "late_preterm_early", "late_preterm_late"]

    if (prematureValues.includes(value)) {
      this.prematureModuleTarget.classList.remove("hidden")
    } else {
      this.prematureModuleTarget.classList.add("hidden")
    }
  }

  // Toggle feeding details visibility based on complementary feeding checkbox
  toggleFeeding() {
    const checked = this.feedingTriggerTarget.checked

    if (checked) {
      this.feedingDetailsTarget.classList.remove("hidden")
    } else {
      this.feedingDetailsTarget.classList.add("hidden")
    }
  }

  // Toggle hereditary conditions list visibility
  toggleHereditary() {
    const checked = this.hereditaryTriggerTarget.checked

    if (checked) {
      this.hereditaryDetailsTarget.classList.remove("hidden")
    } else {
      this.hereditaryDetailsTarget.classList.add("hidden")
    }
  }
}
