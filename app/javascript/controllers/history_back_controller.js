import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  go(event) {
    event.preventDefault()
    if (window.history.length > 1) {
      window.history.back()
    } else {
      window.location.href = "/today"
    }
  }
}
