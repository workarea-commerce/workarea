import { Controller } from "stimulus"
import { config } from "../../workarea"

export default class extends Controller {
  get message() {
    return this.data.get("message") || config.deletion.message
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
    if (window.confirm(this.message)) {
      this.element.dispatchEvent(this.confirmed)
    } else {
      event.preventDefault()
      event.stopAllPropagation()
      this.element.dispatchEvent(this.canceled)
    }
  }
}
