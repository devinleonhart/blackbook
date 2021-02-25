/* eslint no-console:0 */

// Unobtrusive JS and Turbolinks
import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"

// Active Storage
import * as ActiveStorage from "@rails/activestorage"

// Action Text + Trix Editor
require("@rails/actiontext")
require("trix/dist/trix.js")
require("trix/dist/trix.css")

// Bootstrap
import 'bootstrap/dist/js/bootstrap.bundle.min.js';

// Constructors and Loaders
Rails.start()
Turbolinks.start()
ActiveStorage.start()

// Images
const images = require.context('../images', true);

// Custom Styling
import '../stylesheets/application.scss';
