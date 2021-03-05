// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";

Rails.start();
Turbolinks.start();
ActiveStorage.start();

// Action Text + Trix Editor
require("@rails/actiontext");
require("trix/dist/trix.js");
require("trix/dist/trix.css");

// Bootstrap
import 'bootstrap/dist/js/bootstrap.bundle.min.js';
import 'bootstrap/dist/css/bootstrap.min.css';
import 'bootstrap-icons/font/bootstrap-icons.css';

// Images
const images = require.context('./images', true);
const imagePath = name => images(name, true)

// Fonts
const fonts = require.context('./fonts', true);
const fontPath = name => fonts(name, true)

// Custom Styling
import './stylesheets/application.scss';
