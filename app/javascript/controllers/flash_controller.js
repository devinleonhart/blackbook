import { Controller } from "@hotwired/stimulus"

// Auto-fades a flash message after a delay; the close button dismisses early.
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
