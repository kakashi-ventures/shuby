import { Controller } from "@hotwired/stimulus"

// Gemini-style scroll behavior for the chat surface:
//   • connect → anchor the latest message at the bottom of the viewport
//     (history view).
//   • user submits → smooth-scroll the new user message to the top of
//     #messages-container so the AI response has room to stream in
//     below. CSS provides a tall padding-block-end on the message stack
//     to guarantee this works even on short chats.
//   • AI token streaming → no scroll. We discriminate at the Turbo
//     Stream layer: only `append` actions adding a user bubble trigger
//     a scroll; `replace` actions (every streamed token + final
//     swap-in) do not.
//   • manual scroll → respected at all times.
export default class extends Controller {
    static targets = ["messages", "input"]
    static values = { chatId: Number }

    connect() {
        this.scrollToBottom()
        this.handleStream = this.handleBeforeStreamRender.bind(this)
        document.addEventListener("turbo:before-stream-render", this.handleStream)
    }

    disconnect() {
        document.removeEventListener("turbo:before-stream-render", this.handleStream)
    }

    handleBeforeStreamRender(event) {
        const stream = event.target
        if (stream.getAttribute("action") !== "append") return
        if (stream.getAttribute("target") !== "messages") return

        const fragment = stream.templateContent
        if (!fragment.querySelector(".shuby-chat-bubble-user")) return

        const newId = fragment.querySelector("[id]")?.id
        if (!newId) return

        requestAnimationFrame(() => {
            document.getElementById(newId)?.scrollIntoView({ block: "start", behavior: "smooth" })
        })
    }

    scrollToBottom() {
        if (!this.hasMessagesTarget) return
        const lastChild = this.messagesTarget.querySelector("#messages")?.lastElementChild
        if (lastChild) {
            lastChild.scrollIntoView({ block: "end", behavior: "instant" })
        } else {
            this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
        }
    }
}
