import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    create: { type: Boolean, default: true},
    placeholder: String
  }

  connect() {
    this.instance = new TomSelect(this.element, {
      create: this.createValue,
      placeholder: this.placeholderValue,
      plugins: ["remove_button"]
    })
  }

  disconnect() {
    this.instance.destroy()
  }
}