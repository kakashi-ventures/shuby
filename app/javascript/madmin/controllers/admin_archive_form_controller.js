import { Controller } from "@hotwired/stimulus"

// Toggles visibility of content-type-specific field sections
// and filters the category dropdown based on selected content type.
export default class extends Controller {
  static targets = ["tipFields", "activityFields", "categoryFields"]
  static values = { categories: Object }

  connect() {
    this.toggle()
  }

  toggle() {
    const select = this.element.querySelector("[name*='content_type']")
    if (!select) return

    const value = select.value

    if (this.hasTipFieldsTarget) {
      this.tipFieldsTarget.style.display = (value === "tip") ? "" : "none"
    }
    if (this.hasActivityFieldsTarget) {
      this.activityFieldsTarget.style.display = (value === "activity") ? "" : "none"
    }
    if (this.hasCategoryFieldsTarget) {
      this.categoryFieldsTarget.style.display = (value === "activity") ? "none" : ""
    }

    this.#filterCategories(value)
  }

  #filterCategories(contentType) {
    const categorySelect = this.element.querySelector("#archive_content_category")
    if (!categorySelect) return

    const allowed = this.categoriesValue[contentType] || []
    const currentValue = categorySelect.value

    Array.from(categorySelect.options).forEach(option => {
      if (option.value === "") return // keep the prompt option
      option.hidden = allowed.length > 0 && !allowed.includes(option.value)
    })

    // Clear selection if current value is no longer valid
    if (allowed.length > 0 && currentValue && !allowed.includes(currentValue)) {
      categorySelect.value = ""
    }
  }
}
