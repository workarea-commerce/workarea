import { Controller } from "stimulus"
import debounce from "lodash.debounce"
import { config } from "../../workarea"

export default class extends Controller {
  /**
   * Debounce actions
   */
  initialize() {
    const { changeDelay, inputDelay } = config.autosubmit
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
