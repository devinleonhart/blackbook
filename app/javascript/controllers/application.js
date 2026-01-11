// Stimulus application instance.
// Controllers are auto-loaded by index.js.

import { Application } from "@hotwired/stimulus"

const application = Application.start()
application.debug = false
window.Stimulus = application

export { application }
