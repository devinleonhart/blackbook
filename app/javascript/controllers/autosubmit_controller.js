import { Controller } from "@hotwired/stimulus"

// Submits the element's form when it changes.
// <select data-controller="autosubmit" data-action="change->autosubmit#submit">
export default class extends Controller {
  submit() {
    this.element.form.requestSubmit()
  }
}
