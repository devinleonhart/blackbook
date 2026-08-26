import { Controller } from "@hotwired/stimulus"

// Filters a list of items by a typed search term, matching on each item's
// data-filter-text attribute when present, otherwise its text content.
export default class extends Controller {
  static targets = ["query", "item"]

  apply() {
    const term = this.queryTarget.value.trim().toLowerCase()

    this.itemTargets.forEach((item) => {
      const text = (item.dataset.filterText ?? item.textContent).toLowerCase()
      item.classList.toggle("hidden", !text.includes(term))
    })
  }
}
