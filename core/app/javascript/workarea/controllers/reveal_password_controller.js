import { Controller } from "stimulus"
import ButtonTemplate from "../templates/reveal_password_button.ejs"

export default class extends Controller {
  static targets = ["input", "show", "hide"]

  /**
   * Add the button to markup
   */
  connect() {
    const template = document.createElement("template")
    template.innerHTML = ButtonTemplate()
    const button = template.content.firstChild

    this.element.appendChild(button)
  }

  /**
   * Reveal the password and render the "Hide" button
   */
  show() {
    this.showTarget.addClass("hidden")
    this.hideTarget.removeClass("hidden")
    this.inputTarget.setAttribute("type", "text")
  }

  /**
   * Mask the password and render the "Show" button
   */
  hide() {
    this.hideTarget.addClass("hidden")
    this.showTarget.removeClass("hidden")
    this.inputTarget.setAttribute("type", "password")
  }
}
