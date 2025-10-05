import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = {
    create: { type: Boolean, default: true},
    placeholder: String
  }

  connect() {
    console.log("Tom Select controller connecting...")
    
    const currentValue = this.element.value
    const tags = currentValue ? currentValue.split(',').map(tag => tag.trim()).filter(tag => tag) : []
    
    console.log("Current value:", currentValue)
    console.log("Parsed tags:", tags)
    
    this.instance = new TomSelect(this.element, {
      create: this.createValue,
      placeholder: this.placeholderValue,
      plugins: ["remove_button"],
      persist: false,
      createOnBlur: true,
      delimiter: ',',
      options: tags.map(tag => ({ value: tag, text: tag })),
      items: tags
    })
    
    console.log("Tom Select instance created")
  }

  disconnect() {
    if (this.instance) {
      this.instance.destroy()
    }
  }
}