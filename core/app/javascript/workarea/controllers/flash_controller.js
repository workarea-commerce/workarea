import { Controller } from "stimulus"
import { capitalCase as titleize } from "change-case"

export default class FlashController extends Controller {
  get template() {
    throw new Error("Must provide a template for FlashController")
  }

  /**
   * Load flash messages when remote requests complete
   */
  connect() {
    const remotes = "form[data-remote], a[data-remote]"
    const event = "ajax:complete"

    document.querySelectorAll(remotes)
            .forEach(remote => remote.addEventListener(event, this.render))
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

      this.element.append(message)
    })
  }
}
