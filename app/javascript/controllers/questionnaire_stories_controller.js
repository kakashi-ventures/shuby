import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "progress", "answerGroup"]
  static values = {
    childId: Number,
    sessionId: Number,
    total: Number,
    current: { type: Number, default: 0 },
    exitConfirmation: String
  }

  connect() {
    this.showSlide(this.currentValue)
    this.updateProgress()
    this.setupSwipeGestures()
    this.setupKeyboardNavigation()
    // Notify the outer overlay controller of the initial slide so the
    // background color matches (e.g. reopening a completed session lands
    // on the completion slide directly).
    this.dispatchSlideChanged(this.currentValue)
  }

  disconnect() {
    this.teardownSwipeGestures()
    this.teardownKeyboardNavigation()
  }

  // Navigation
  next() {
    if (this.currentValue < this.slideTargets.length - 1) {
      this.transitionTo(this.currentValue + 1, "forward")
    }
  }

  previous() {
    if (this.currentValue > 0) {
      this.transitionTo(this.currentValue - 1, "backward")
    }
  }

  goTo(index) {
    if (index >= 0 && index < this.slideTargets.length) {
      const direction = index > this.currentValue ? "forward" : "backward"
      this.transitionTo(index, direction)
    }
  }

  // Answer handling
  async answer(event) {
    const button = event.currentTarget
    const questionId = button.dataset.questionId
    const answer = button.dataset.answer

    // Visual feedback
    this.highlightAnswer(button)
    this.disableAnswerButtons(button)

    try {
      // Submit answer to server
      const response = await this.submitAnswer(questionId, answer)

      if (response.ok) {
        const data = await response.json()

        // Signal the outer overlay controller that this answer completed
        // the session, so it knows to refresh the caller page on close
        // (e.g. dashboard milestone box rotates to the next area or
        // flips to the all-complete state).
        if (data.completed) {
          window.dispatchEvent(new CustomEvent("questionnaire-overlay:session-completed"))
        }

        // Brief delay for visual feedback, then advance
        setTimeout(() => {
          this.next()
        }, 300)
      } else {
        this.handleError()
      }
    } catch (error) {
      console.error("Answer submission failed:", error)
      this.handleError()
    }
  }

  async submitAnswer(questionId, answer) {
    const url = `/children/${this.childIdValue}/questionnaires/${this.sessionIdValue}/answer`

    return fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfToken,
        "Accept": "application/json"
      },
      body: JSON.stringify({
        question_id: questionId,
        answer: answer
      })
    })
  }

  get csrfToken() {
    const meta = document.querySelector("[name='csrf-token']")
    return meta ? meta.content : ""
  }

  // Slide transitions are INSTANT per Figma prototype (SWAP action with
  // no transition data on every intra-overlay transition). The `direction`
  // param is preserved in the signature for callers but unused — kept in
  // case future motion is reintroduced.
  transitionTo(newIndex, _direction) {
    const currentSlide = this.slideTargets[this.currentValue]
    const nextSlide = this.slideTargets[newIndex]

    currentSlide.classList.remove("active")
    nextSlide.classList.add("active")

    this.currentValue = newIndex
    this.updateProgress()
    this.dispatchSlideChanged(newIndex)
    this.focusFirstInteractive(nextSlide)
  }

  // Broadcast to the outer overlay controller so it can flip background
  // color + close-button contrast when the user lands on the completion
  // slide (last index). See `questionnaire_overlay_controller#onSlideChanged`.
  dispatchSlideChanged(index) {
    const total = this.slideTargets.length
    window.dispatchEvent(new CustomEvent("questionnaire-overlay:slide-changed", {
      detail: { index, total, isCompletion: index === total - 1 }
    }))
  }

  showSlide(index) {
    this.slideTargets.forEach((slide, i) => {
      slide.classList.toggle("active", i === index)
    })
  }

  updateProgress() {
    const segments = this.progressTarget.querySelectorAll(".stories-progress-segment")
    segments.forEach((segment, i) => {
      segment.classList.remove("completed", "current")
      if (i < this.currentValue) {
        segment.classList.add("completed")
      } else if (i === this.currentValue) {
        segment.classList.add("current")
      }
    })
  }

  highlightAnswer(button) {
    const group = button.closest("[data-questionnaire-stories-target='answerGroup']")
    if (group) {
      group.querySelectorAll(".stories-answer-btn").forEach(btn => {
        btn.classList.remove("selected")
      })
    }
    button.classList.add("selected")
  }

  disableAnswerButtons(clickedButton) {
    const group = clickedButton.closest("[data-questionnaire-stories-target='answerGroup']")
    if (group) {
      group.querySelectorAll(".stories-answer-btn").forEach(btn => {
        btn.disabled = true
      })
    }
  }

  enableAnswerButtons() {
    this.answerGroupTargets.forEach(group => {
      group.querySelectorAll(".stories-answer-btn").forEach(btn => {
        btn.disabled = false
        btn.classList.remove("selected")
      })
    })
  }

  focusFirstInteractive(slide) {
    const focusable = slide.querySelector("button:not([disabled]), a[href], input:not([disabled])")
    if (focusable) {
      focusable.focus()
    }
  }

  // Swipe gestures for mobile
  setupSwipeGestures() {
    this.touchStartX = 0
    this.touchEndX = 0

    this.handleTouchStart = (e) => {
      this.touchStartX = e.changedTouches[0].screenX
    }

    this.handleTouchEnd = (e) => {
      this.touchEndX = e.changedTouches[0].screenX
      this.handleSwipe()
    }

    this.element.addEventListener("touchstart", this.handleTouchStart, { passive: true })
    this.element.addEventListener("touchend", this.handleTouchEnd, { passive: true })
  }

  handleSwipe() {
    const threshold = 50
    const diff = this.touchStartX - this.touchEndX

    // Only allow swipe back on non-question slides (intro or completion)
    const isQuestionSlide = this.currentValue > 0 && this.currentValue < this.slideTargets.length - 1

    if (diff < -threshold && this.currentValue > 0 && !isQuestionSlide) {
      // Swipe right = go back (only on intro/completion)
      this.previous()
    }
  }

  teardownSwipeGestures() {
    if (this.handleTouchStart) {
      this.element.removeEventListener("touchstart", this.handleTouchStart)
    }
    if (this.handleTouchEnd) {
      this.element.removeEventListener("touchend", this.handleTouchEnd)
    }
  }

  // Keyboard navigation
  setupKeyboardNavigation() {
    this.handleKeydown = (e) => {
      // Skip if user is typing in an input
      if (e.target.tagName === "INPUT" || e.target.tagName === "TEXTAREA") {
        return
      }

      switch (e.key) {
        case "ArrowRight":
        case "Enter":
          // Only on intro slide
          if (this.currentValue === 0) {
            e.preventDefault()
            this.next()
          }
          break
        case "ArrowLeft":
        case "Escape":
          if (this.currentValue === 0) {
            e.preventDefault()
            this.exit()
          }
          break
        case "1":
          e.preventDefault()
          this.answerByKey("si")
          break
        case "2":
          e.preventDefault()
          this.answerByKey("no")
          break
        case "3":
          e.preventDefault()
          this.answerByKey("incerto")
          break
      }
    }

    document.addEventListener("keydown", this.handleKeydown)
  }

  teardownKeyboardNavigation() {
    if (this.handleKeydown) {
      document.removeEventListener("keydown", this.handleKeydown)
    }
  }

  answerByKey(answer) {
    // Find the active slide's answer group
    const activeSlide = this.slideTargets.find(slide => slide.classList.contains("active"))
    if (!activeSlide) return

    const answerGroup = activeSlide.querySelector("[data-questionnaire-stories-target='answerGroup']")
    if (!answerGroup) return

    const button = answerGroup.querySelector(`[data-answer="${answer}"]`)
    if (button && !button.disabled) {
      button.click()
    }
  }

  // Exit handling — progress persists per-answer via AJAX, so closing is
  // non-destructive. Bubble a close event the outer overlay controller
  // listens for.
  exit() {
    window.dispatchEvent(new CustomEvent("questionnaire-overlay:close"))
  }

  handleError() {
    // Re-enable buttons
    this.enableAnswerButtons()

    // Show error toast if available
    const event = new CustomEvent("toast:show", {
      detail: {
        type: "error",
        message: "Si è verificato un errore. Riprova."
      }
    })
    window.dispatchEvent(event)
  }
}
