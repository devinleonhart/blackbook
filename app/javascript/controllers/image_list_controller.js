import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.refresh()
  }

  refresh() {
    if (!this.isMobileLike()) return

    const images = this.element.querySelectorAll("img[data-reloadable-image]")

    images.forEach((img) => {
      if (img.complete && img.naturalWidth > 0) return

      const src = img.dataset.originalSrc || img.currentSrc || img.src
      if (!src) return

      img.dataset.originalSrc ||= src
      img.removeAttribute("srcset")
      img.src = ""
      img.src = src
    })
  }

  isMobileLike() {
    if (window.matchMedia && window.matchMedia("(pointer: coarse)").matches) return true
    return window.innerWidth < 768
  }
}
