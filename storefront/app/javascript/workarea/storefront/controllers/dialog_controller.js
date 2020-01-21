import { Controller } from "stimulus"
import Dialog from "../templates/dialog.ejs"
import Loading from "../templates/loading.ejs"
import template from "../utils/template"
import close from "../images/dialog_close.svg"

/**
 * Dialog windows in the storefront are loaded via UJS remote forms and
 * links, using this controller as a helper for rendering their content
 * in an EJS template and managing loading indicators.
 */
export default class extends Controller {
  /**
   * Render a new dialog to the DOM by appending it to the `<body>` element
   */
  static render(title, content, type) {
    const dialog = template(Dialog, { title, type, content, close })

    document.body.append(dialog)
  }

  /**
   * Create a loading indicator in a dialog while the ajax request
   * completes.
   */
  load() {
    const text = I18n.t("workarea.messages.loading")
    const loading = template(Loading, { text })

    this.constructor.render(text, loading, "loading")
  }

  /**
   * Remove all loading dialogs and render content in its place
   */
  create({ detail: [ content, _status, xhr ] }) {
    const title = xhr.getResponseHeader("X-Page-Title")
    const type = "content"
    const loading = document.querySelectorAll('[data-dialog-type="loading"]')

    loading.forEach(element => element.remove())

    this.constructor.render(title, content, type)
  }

  /**
   * Close the current dialog by fading it out
   */
  close() {
    this.element.classList.addClass("dialog--close")
  }

  /**
   * When the animation finishes, remove the dialog from the DOM
   */
  remove() {
    this.element.remove()
  }
}
