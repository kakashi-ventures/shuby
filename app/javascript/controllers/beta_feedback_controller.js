import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "form", "preview", "screenshotSection", "sectionField", "urlField"]
  static values = { capturing: { type: Boolean, default: false } }

  connect() {
    this.screenshotBlob = null
  }

  disconnect() {
    this.screenshotBlob = null
  }

  async open() {
    if (this.capturingValue) return
    this.capturingValue = true

    try {
      await this.captureScreenshot()
    } catch (error) {
      console.warn("Screenshot capture failed:", error)
    }

    this.urlFieldTarget.value = window.location.pathname
    this.sectionFieldTarget.value = this.detectSection(window.location.pathname)

    this.modalTarget.showModal()
    this.capturingValue = false
  }

  close() {
    this.modalTarget.close()
    this.resetForm()
  }

  backdropClose(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  async captureScreenshot() {
    const { domToBlob } = await import("modern-screenshot")
    this.screenshotBlob = await domToBlob(document.body, {
      scale: 1,
      quality: 0.7,
      type: "image/jpeg",
      width: window.innerWidth,
      height: window.innerHeight
    })

    if (this.screenshotBlob && this.hasPreviewTarget) {
      this.previewTarget.src = URL.createObjectURL(this.screenshotBlob)
      if (this.hasScreenshotSectionTarget) this.screenshotSectionTarget.classList.remove("hidden")
    }
  }

  detectSection(path) {
    if (path === "/" || path === "/today") return "dashboard"
    const segments = path.replace(/^\//, "").split("/")
    const first = segments[0]

    const mapping = {
      children: () => segments[2]?.replace(/-/g, "_") || "children",
      archive: () => "archive",
      shuby: () => "shuby",
      settings: () => "settings",
      today: () => "dashboard",
      "family-profiles": () => "family_profiles",
      "pediatrician-reports": () => "pediatrician_reports",
      onboarding: () => "onboarding"
    }

    const resolver = mapping[first]
    return resolver ? resolver() : "other"
  }

  async submit(event) {
    event.preventDefault()
    const formData = new FormData(this.formTarget)

    if (this.screenshotBlob) {
      formData.append("beta_feedback[screenshot]", this.screenshotBlob, "screenshot.jpg")
    }

    const metadata = {
      user_agent: navigator.userAgent,
      screen_width: window.screen.width,
      screen_height: window.screen.height,
      viewport_width: window.innerWidth,
      viewport_height: window.innerHeight,
      hotwire_native: document.documentElement.classList.contains("hotwire-native"),
      timestamp: new Date().toISOString()
    }
    formData.append("beta_feedback[metadata]", JSON.stringify(metadata))

    try {
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        headers: {
          "X-CSRF-Token": this.csrfToken,
          "Accept": "text/vnd.turbo-stream.html"
        },
        body: formData
      })

      if (response.ok) {
        this.close()
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      } else {
        const html = await response.text()
        Turbo.renderStreamMessage(html)
      }
    } catch (error) {
      console.error("Feedback submission failed:", error)
    }
  }

  resetForm() {
    if (this.hasFormTarget) this.formTarget.reset()
    this.screenshotBlob = null
    if (this.hasScreenshotSectionTarget) this.screenshotSectionTarget.classList.add("hidden")
    if (this.hasPreviewTarget) this.previewTarget.src = ""
  }

  get csrfToken() {
    return document.querySelector("[name='csrf-token']")?.content || ""
  }
}
