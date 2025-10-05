import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

export default class extends Controller {
  static values = { 
    placeholder: { type: String, default: "Add tags..." },
    maxItems: { type: Number, default: null }
  }

  connect() {
    console.log("Tom Select Tags controller connecting...")
    console.log("Element:", this.element)
    console.log("TomSelect:", TomSelect)
    
    const currentValue = this.element.value
    const tags = currentValue ? currentValue.split(',').map(tag => tag.trim()).filter(tag => tag) : []
    
    console.log("Current value:", currentValue)
    console.log("Parsed tags:", tags)
    
    try {
      this.instance = new TomSelect(this.element, {
        plugins: ['remove_button'],
        persist: false,
        createOnBlur: true,
        create: true,
        delimiter: ',',
        placeholder: this.placeholderValue,
        maxItems: this.maxItemsValue,
        options: tags.map(tag => ({ value: tag, text: tag })),
        items: tags
      })
      console.log("Tom Select instance created:", this.instance)
    } catch (error) {
      console.error("Error creating Tom Select:", error)
    }
  }

  disconnect() {
    if (this.instance) {
      this.instance.destroy()
    }
  }
}