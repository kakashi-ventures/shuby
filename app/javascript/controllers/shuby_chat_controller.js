import { Controller } from "@hotwired/stimulus"

// Scrolls the messages container to the latest message once on connect
// (so reopening a chat lands on the most recent turn). Intentionally
// does NOT auto-scroll on submit or during AI token streaming — the
// viewport should stay where the user left it while tokens stream in
// below. Manual scroll is the only mechanism that moves the view after
// the initial load.
export default class extends Controller {
    static targets = ["messages", "input"]
    static values = { chatId: Number }

    connect() {
        this.scrollToBottom()
    }

    scrollToBottom() {
        if (this.hasMessagesTarget) {
            this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
        }
    }
}
