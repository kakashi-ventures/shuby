import { Controller } from "@hotwired/stimulus"

// Surfaces iOS Password AutoFill (Face ID / Touch ID fills the saved
// credentials) for the login form. Wire the <form> with
// `data-controller="biometric-login"`, the email input with
// `data-biometric-login-target="email"`, and the round Face-ID button with
// `data-action="biometric-login#prompt"`.
//
// The iOS shell exposes the keychain because the app's associated domains are
// configured (config/ruby_native.yml) and the fields carry autocomplete
// attributes. Focusing the email field inside the button's click gesture nudges
// WKWebView/Safari to present the AutoFill bar. On desktop browsers the native
// password manager prompt appears instead. True tap-to-authenticate via
// passkeys/WebAuthn is a separate feature (see docs/REMAINING-WORK.md).
export default class extends Controller {
  static targets = ["email"]

  prompt() {
    if (!this.hasEmailTarget) return

    this.emailTarget.focus()
    // Re-dispatch a focus so the autofill affordance reliably appears even if
    // the field was already focused.
    this.emailTarget.dispatchEvent(new Event("focus", { bubbles: false }))
  }
}
