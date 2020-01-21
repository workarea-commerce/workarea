import { Controller } from "stimulus"
import I18n from "@workarea/core/i18n"

export default class extends Controller {
  static targets = ["button", "input"]

  /**
   * Save off the original button's text
   */
  connect() {
    this.originalText = this.buttonTarget.innerText
  }

  /**
   * Copy the text in the input target to the clipboard, notify the user
   * in the button text, then restore original button text after 3
   * seconds.
   */
  copy(event) {
    const range = document.createRange()

    range.selectNode(this.inputTarget)

    window.getSelection()
          .addRange(range)

    if (document.execCommand('copy')) {
      this.buttonTarget.innerText = I18n.t('workarea.messages.copied')
    } else {
      this.buttonTarget.innerText = I18n.t('workarea.messages.copy_failed')
    }

    window.setTimeout(this.restore, 3000)
  }

  /**
   * Restore text back to the button
   */
  restore() {
    this.buttonTarget.innerText = this.originalText
  }
}
