import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "button"]

  connect() {
    this.hide()
    this.beforeCacheHandler = () => this.hide()
    document.addEventListener("turbo:before-cache", this.beforeCacheHandler)
  }

  disconnect() {
    document.removeEventListener("turbo:before-cache", this.beforeCacheHandler)
  }

  toggle() {
    if (!this.hasMenuTarget) return

    const isHidden = this.menuTarget.classList.contains("hidden")
    if (isHidden) this.show()
    else this.hide()
  }

  show() {
    if (this.hasMenuTarget) this.menuTarget.classList.remove("hidden")
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", "true")
  }

  hide() {
    if (this.hasMenuTarget) this.menuTarget.classList.add("hidden")
    if (this.hasButtonTarget) this.buttonTarget.setAttribute("aria-expanded", "false")
  }
}

