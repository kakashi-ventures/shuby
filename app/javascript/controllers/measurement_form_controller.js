import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["valueInput", "photoPreview", "photoPlaceholder", "removePhoto", "removePhotoField"]
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
