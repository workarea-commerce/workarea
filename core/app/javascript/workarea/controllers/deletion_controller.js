import { Controller } from "stimulus"

export default class extends Controller {
  get message() {
    return this.data.get("message")
  }

  get confirmed() {
    return new Event("deletionForm:confirmed")
  }

  get canceled() {
    return new Event("deletionForm:canceled")
  }

  /**
   * Confirm before submitting the form, then fire an event based on
   * whether the confirmation was successful.
   */
  submit(event) {
    if (this.message && window.confirm(this.message)) {
      this.element.dispatchEvent(this.confirmed)
      return
    }

    event.preventDefault()
    event.stopAllPropagation()
    this.element.dispatchEvent(this.canceled)
  }
}
