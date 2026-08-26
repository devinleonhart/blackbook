import { Controller } from "@hotwired/stimulus"

// Submits the element's form when it changes.
export default class extends Controller {
  submit() {
    this.element.form.requestSubmit()
  }
}
