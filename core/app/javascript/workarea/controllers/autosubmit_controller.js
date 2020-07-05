import { Controller } from "stimulus"
import debounce from "lodash.debounce"

export default class extends Controller {
  get config() {
    return this.app.config.autosubmit
  }

  /**
   * Debounce actions
   */
  initialize() {
    const { changeDelay, inputDelay } = this.config
    this.change = debounce(this.submit, changeDelay)
    this.input = debounce(this.submit, inputDelay)
  }

  /**
   * Submit the form when an input is changed.
   */
  submit() {
    const event = new Event("submit")

    this.element.dispatchEvent(event)
  }
}
