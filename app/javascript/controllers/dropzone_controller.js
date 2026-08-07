import { Controller } from "@hotwired/stimulus"

// Drag-and-drop (or click) bulk image upload. Posts the dropped image files to
// the universe's images endpoint in one request; on a character page it also
// sends character_id so each new image is tagged with that character. On
// success it Turbo-refreshes the page to show the new images.
export default class extends Controller {
  static values = { url: String, characterId: Number }
  static targets = ["input", "status", "prompt"]
  static classes = ["dragover"]

  open() {
    if (!this.uploading) this.inputTarget.click()
  }

  picked() {
    if (this.inputTarget.files.length) this.upload([...this.inputTarget.files])
  }

  dragover(event) {
    event.preventDefault()
    this.element.classList.add(...this.dragoverClasses)
  }

  dragleave(event) {
    event.preventDefault()
    this.element.classList.remove(...this.dragoverClasses)
  }

  drop(event) {
    event.preventDefault()
    this.element.classList.remove(...this.dragoverClasses)
    const files = [...event.dataTransfer.files].filter((f) => f.type.startsWith("image/"))
    if (files.length) this.upload(files)
  }

  async upload(files) {
    if (this.uploading) return
    this.uploading = true
    this.setStatus(`Uploading ${files.length} image${files.length === 1 ? "" : "s"}…`)

    const body = new FormData()
    for (const file of files) body.append("image[image_file][]", file)
    if (this.hasCharacterIdValue) body.append("character_id", this.characterIdValue)

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: { Accept: "application/json", "X-CSRF-Token": this.csrfToken() },
        body,
        credentials: "same-origin",
      })
      const data = await response.json().catch(() => ({}))
      if (!response.ok) throw new Error(data.error || `Upload failed (${response.status})`)

      const tagged = data.tagged ? ` · tagged ${data.tagged}` : ""
      this.setStatus(`Uploaded ${data.created} image${data.created === 1 ? "" : "s"}${tagged} ✓`)
      setTimeout(() => this.refresh(), 700)
    } catch (error) {
      this.setStatus(`Upload failed: ${error.message}`)
      this.uploading = false
    }
  }

  refresh() {
    if (window.Turbo) window.Turbo.visit(window.location.href, { action: "replace" })
    else window.location.reload()
  }

  setStatus(text) {
    if (this.hasPromptTarget) this.promptTarget.classList.add("hidden")
    if (!this.hasStatusTarget) return
    this.statusTarget.textContent = text
    this.statusTarget.classList.remove("hidden")
  }

  csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
