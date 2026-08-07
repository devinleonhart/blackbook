import { Controller } from "@hotwired/stimulus"

// Collapsible disclosure. Used to tuck the sidebar tools behind a toggle on
// small screens while a `lg:block` on the content keeps them always visible on
// desktop (where the toggle button itself is hidden via lg:hidden).
export default class extends Controller {
  static targets = ["content", "icon", "button"]

  toggle() {
    const open = !this.contentTarget.classList.toggle("hidden")
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", String(open))
    if (this.hasIconTarget) this.iconTarget.classList.toggle("rotate-180", open)
  }
}
