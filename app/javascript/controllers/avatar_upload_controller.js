import { Controller } from "@hotwired/stimulus"

// Live-preview an image selected via a hidden <input type="file">. Wire the
// input with `data-action="change->avatar-upload#preview"` and the <img>
// being swapped with `data-avatar-upload-target="preview"`. Optionally mark a
// fallback element (icon placeholder) with `data-avatar-upload-target="placeholder"`
// to hide it on selection. The placeholder target is optional — the controller
// works on both the child form (has placeholder) and the user form (no placeholder,
// because the Gravatar URL is always rendered as the initial preview).
export default class extends Controller {
  static targets = ["preview", "placeholder"]

  preview(event) {
    const file = event.target.files?.[0]
    if (!file) return

    const reader = new FileReader()
    reader.onload = (e) => {
      if (this.hasPreviewTarget) {
        this.previewTarget.src = e.target.result
        this.previewTarget.classList.remove("hidden")
      }
      if (this.hasPlaceholderTarget) {
        this.placeholderTarget.classList.add("hidden")
      }
    }
    reader.readAsDataURL(file)
  }
}
