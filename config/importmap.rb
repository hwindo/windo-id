# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"
pin "tom-select" # @2.4.3
pin "@orchidjs/sifter", to: "@orchidjs--sifter.js" # @1.1.0
pin "@orchidjs/unicode-variants", to: "@orchidjs--unicode-variants.js" # @1.1.2
