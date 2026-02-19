import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["valueInput"]
  static values = { placeholders: { type: Object, default: {} } }

  typeChanged(event) {
    const selectedType = event.target.value
    this.updateActiveTab(event.target)
    this.updatePlaceholder(selectedType)
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
}
