import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autosubmit"
export default class extends Controller {
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this.timeoutId = null
  }

  schedule() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
    }
    this.timeoutId = setTimeout(() => this.submit(), this.delayValue)
  }

  submit() {
    const form = this.element.closest('form') || this.element
    if (form && typeof form.requestSubmit === 'function') {
      form.requestSubmit()
    } else if (form && typeof form.submit === 'function') {
      form.submit()
    }
  }
}


