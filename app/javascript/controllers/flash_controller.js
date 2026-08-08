import { Controller } from "@hotwired/stimulus"

// Fades a flash message out after a few seconds and lets the user dismiss it
// early with the close button. Errors linger longer since they matter more.
export default class extends Controller {
  static values = { delay: { type: Number, default: 5000 } }

  connect() {
    this.timeout = setTimeout(() => this.dismiss(), this.delayValue)
  }

  disconnect() {
    clearTimeout(this.timeout)
  }

  dismiss() {
    clearTimeout(this.timeout)
    this.element.classList.add("bb-alert--dismissing")
    // Remove after the fade transition so it stops taking up space.
    this.element.addEventListener("transitionend", () => this.element.remove(), { once: true })
    // Fallback in case the transition never fires (e.g. reduced motion).
    setTimeout(() => this.element.remove(), 600)
  }
}
