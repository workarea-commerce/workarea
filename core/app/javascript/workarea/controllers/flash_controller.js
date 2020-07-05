import { Controller } from "stimulus"
import { capitalCase as titleize } from "change-case"

export default class FlashController extends Controller {
  static targets = ['message']
  get template() {
    throw new Error("Must provide a template for FlashController")
  }

  /**
   * Render a flash message
   */
  render({ detail: [ xhr ] }) {
    const header = xhr.getResponseHeader("X-Flash-Messages")
    const flash = JSON.parse(header)

    flash.forEach((text, type) => {
      const title = titleize(type)
      const message = this.template({ text, type, title })

      this.element.insertAdjacentHTML("beforeend", message)
    })
  }
}
