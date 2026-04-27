import { Controller } from "@hotwired/stimulus"

// Stimulus controller for the Shuby chat surface — keeps the messages
// container scrolled to the latest message as new messages stream in.
export default class extends Controller {
    static targets = ["messages", "input"]
    static values = { chatId: Number }

    connect() {
        this.scrollToBottom()
        this.observeMessages()
    }

    disconnect() {
        if (this.observer) {
            this.observer.disconnect()
        }
    }

    observeMessages() {
        const messagesContainer = this.hasMessagesTarget
            ? this.messagesTarget
            : document.getElementById("messages")
        if (!messagesContainer) return

        this.observer = new MutationObserver(() => this.scrollToBottom())
        this.observer.observe(messagesContainer, { childList: true, subtree: true })
    }

    scrollToBottom() {
        if (this.hasMessagesTarget) {
            this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
        }
    }
}
