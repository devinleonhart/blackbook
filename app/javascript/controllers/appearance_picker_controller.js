import { Controller } from "@hotwired/stimulus"

// Type-ahead token box for tagging several characters onto an image at once.
// Type to filter, Enter/Tab/click to drop a character token into the box, then
// submit to add them all (handled by Turbo Stream, no reload).
//
// Character options are read from hidden `option` target nodes (data-character-id
// / data-name) rather than an inline <script>, to satisfy the strict CSP.
export default class extends Controller {
  static targets = ["input", "option", "suggestions", "tokens", "submit"]

  connect() {
    this.selected = new Set()
    this.activeIndex = -1
    this.renderSubmit()
  }

  focusInput() {
    this.inputTarget.focus()
  }

  onInput() {
    this.renderSuggestions()
  }

  onKeydown(event) {
    const open = !this.suggestionsTarget.classList.contains("hidden")
    const rows = this.currentRows()

    switch (event.key) {
      case "ArrowDown":
        if (!open || rows.length === 0) return
        event.preventDefault()
        this.moveActive(1, rows)
        break
      case "ArrowUp":
        if (!open || rows.length === 0) return
        event.preventDefault()
        this.moveActive(-1, rows)
        break
      case "Enter":
      case "Tab": {
        // When a suggestion is showing, accept it (and for Tab, keep focus here).
        // Otherwise let the key do its normal thing: Enter submits, Tab moves on.
        const row = rows[this.activeIndex] || rows[0]
        if (open && row) {
          event.preventDefault()
          this.addToken(row.dataset.characterId, row.dataset.name)
        }
        break
      }
      case "Escape":
        this.closeSuggestions()
        break
      case "Backspace":
        if (this.inputTarget.value === "") this.removeLastToken()
        break
      default:
        break
    }
  }

  chooseSuggestion(event) {
    const el = event.currentTarget
    this.addToken(el.dataset.characterId, el.dataset.name)
  }

  removeToken(event) {
    const pill = event.currentTarget.closest(".bb-token")
    if (!pill) return
    this.selected.delete(pill.dataset.characterId)
    pill.remove()
    this.renderSubmit()
    this.inputTarget.focus()
  }

  // --- internals ---

  availableOptions() {
    return this.optionTargets.filter((o) => !this.selected.has(o.dataset.characterId))
  }

  renderSuggestions() {
    const query = this.inputTarget.value.trim().toLowerCase()
    this.suggestionsTarget.innerHTML = ""
    this.activeIndex = -1

    if (query === "") {
      this.closeSuggestions()
      return
    }

    const matches = this.availableOptions()
      .filter((o) => o.dataset.name.toLowerCase().includes(query))
      .slice(0, 8)

    if (matches.length === 0) {
      this.closeSuggestions()
      return
    }

    matches.forEach((o) => {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "bb-token-suggestion"
      btn.setAttribute("role", "option")
      btn.textContent = o.dataset.name
      btn.dataset.characterId = o.dataset.characterId
      btn.dataset.name = o.dataset.name
      btn.dataset.action = "appearance-picker#chooseSuggestion"
      this.suggestionsTarget.appendChild(btn)
    })

    this.activeIndex = 0
    this.highlight()
    this.suggestionsTarget.classList.remove("hidden")
  }

  currentRows() {
    return Array.from(this.suggestionsTarget.querySelectorAll(".bb-token-suggestion"))
  }

  moveActive(delta, rows) {
    this.activeIndex = (this.activeIndex + delta + rows.length) % rows.length
    this.highlight()
  }

  highlight() {
    this.currentRows().forEach((row, i) => {
      row.classList.toggle("bb-token-suggestion--active", i === this.activeIndex)
    })
  }

  addToken(id, name) {
    if (!id || this.selected.has(id)) return
    this.selected.add(id)

    const pill = document.createElement("span")
    pill.className = "bb-token"
    pill.dataset.characterId = id

    const label = document.createElement("span")
    label.textContent = name
    pill.appendChild(label)

    const remove = document.createElement("button")
    remove.type = "button"
    remove.className = "bb-token__remove"
    remove.setAttribute("aria-label", `Remove ${name}`)
    remove.textContent = "×"
    remove.dataset.action = "appearance-picker#removeToken"
    pill.appendChild(remove)

    const hidden = document.createElement("input")
    hidden.type = "hidden"
    hidden.name = "character_ids[]"
    hidden.value = id
    pill.appendChild(hidden)

    this.tokensTarget.appendChild(pill)

    this.inputTarget.value = ""
    this.closeSuggestions()
    this.renderSubmit()
    this.inputTarget.focus()
  }

  removeLastToken() {
    const pills = this.tokensTarget.querySelectorAll(".bb-token")
    const last = pills[pills.length - 1]
    if (!last) return
    this.selected.delete(last.dataset.characterId)
    last.remove()
    this.renderSubmit()
  }

  closeSuggestions() {
    this.suggestionsTarget.classList.add("hidden")
    this.suggestionsTarget.innerHTML = ""
    this.activeIndex = -1
  }

  renderSubmit() {
    const count = this.selected.size
    this.submitTarget.disabled = count === 0
    this.submitTarget.textContent =
      count === 0 ? "Add characters" : `Add ${count} character${count === 1 ? "" : "s"}`
  }
}
