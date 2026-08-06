import { Controller } from "@hotwired/stimulus"

// Filters a list of items by a typed search term. Each item is matched on its
// data-filter-text attribute when present, otherwise its text content.
//
//   <div data-controller="filter">
//     <input data-filter-target="query" data-action="input->filter#apply">
//     <div data-filter-target="item" data-filter-text="...">…</div>
//   </div>
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
