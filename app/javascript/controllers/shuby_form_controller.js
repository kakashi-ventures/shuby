import { Controller } from "@hotwired/stimulus"

// Stimulus controller for the Shuby chat composer pill.
// Handles submission, keyboard shortcut, autoresize, and the mic↔send
// icon swap driven by `data-icon-state` on the submit button.
export default class extends Controller {
    static targets = ["input", "submit"]

    connect() {
        this.syncIconState()
        this.autoResize()
        this.element.addEventListener("turbo:submit-end", this.onSubmitEnd.bind(this))
    }

    disconnect() {
        this.element.removeEventListener("turbo:submit-end", this.onSubmitEnd.bind(this))
    }

    submit(event) {
        const message = this.inputTarget.value.trim()
        if (!message) {
            event.preventDefault()
            return
        }
        if (this.hasSubmitTarget) {
            this.submitTarget.disabled = true
        }
    }

    onSubmitEnd(event) {
        this.inputTarget.value = ""
        this.autoResize()
        this.syncIconState()
        if (this.hasSubmitTarget) {
            this.submitTarget.disabled = false
        }
    }

    handleKeydown(event) {
        if (event.key === "Enter" && !event.shiftKey) {
            event.preventDefault()
            const form = this.element.closest("form") || this.element
            if (form.requestSubmit) {
                form.requestSubmit()
            } else {
                form.submit()
            }
        }
    }

    // Combined input handler: keep textarea sized to content and toggle the
    // mic↔send icon based on whether there's text to send.
    onInput() {
        this.autoResize()
        this.syncIconState()
    }

    autoResize() {
        if (!this.hasInputTarget) return
        const input = this.inputTarget
        input.style.height = "auto"
        input.style.height = Math.min(input.scrollHeight, 120) + "px"
    }

    syncIconState() {
        if (!this.hasSubmitTarget || !this.hasInputTarget) return
        const hasText = this.inputTarget.value.trim().length > 0
        this.submitTarget.dataset.iconState = hasText ? "typing" : "empty"
    }
}
