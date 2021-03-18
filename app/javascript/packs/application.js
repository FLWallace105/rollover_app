// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.
require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"

import jquery from 'jquery';
window.$ = window.jquery = jquery;

import "bootstrap"
import "../stylesheets/application"
// import "bootstrap/dist/js/bootstrap"
import "jquery/dist/jquery"
import "popper.js/dist/esm/popper"
import flatpickr from "flatpickr";

Rails.start()
Turbolinks.start()
ActiveStorage.start()

//= require flatpickr

// document.addEventListener('DOMContentLoaded', function() {
//   flatpickr('.your-selector');
// })

// $('#flatpickr-input').flatpickr();