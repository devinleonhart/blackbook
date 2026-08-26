import { Controller } from "@hotwired/stimulus"

// Collapsible disclosure for tucking sidebar tools behind a toggle on small screens.
export default class extends Controller {
  static targets = ["content", "icon", "button"]

  toggle() {
    const open = !this.contentTarget.classList.toggle("hidden")
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", String(open))
    if (this.hasIconTarget) this.iconTarget.classList.toggle("rotate-180", open)
  }
}
