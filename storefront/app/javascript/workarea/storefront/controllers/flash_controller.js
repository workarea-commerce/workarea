import { Controller } from "stimulus"
import Message from "../templates/message.ejs"
import { titleize } from "../../models/string"

export default class FlashController extends Controller {
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
  render({ detail: [ xhr, _status ] }) {
    const header = xhr.getResponseHeader("X-Flash-Messages")
    const flash = JSON.parse(header)

    flash.forEach((text, type) => {
      const title = titleize(type)
      const message = Message({ text, type, title })

      this.element.append(message)
    })
  }
}
