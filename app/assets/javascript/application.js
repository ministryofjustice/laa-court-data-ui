// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import '../stylesheets/application.scss'
import '@hotwired/turbo'
import Rails from '@rails/ujs'

// Prevent turbo from intercepting form submissions in ways that don't play nicely
// with things like the Rails flash system. Note:
// 1) This avoids the need for having to a add a `data-turbo=false` annotation to
//    individual forms
// 2) This doesn't disable turbo as a whole, so it will still do link-prefetching,
//    and the turbo-frame system used for the cookie banner will still work.
Turbo.config.forms.mode = "off"

Rails.start()

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
