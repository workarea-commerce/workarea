import { Controller } from "stimulus"
import { Editor } from "wysihtml"
import { config } from "admin/application"
import I18n from "workarea/i18n"

import ToolbarTemplate from "../templates/wysiwyg_toolbar.ejs"

import ExpandMoreIcon from "../icons/wysiwyg/expand_more.svg"
import BoldIcon from "../icons/wysiwyg/bold.svg"
import ItalicIcon from "../icons/wysiwyg/italic.svg"
import UnderlineIcon from "../icons/wysiwyg/underline.svg"
import BulletedListIcon from "../icons/wysiwyg/bulleted_list.svg"
import NumberedListIcon from "../icons/wysiwyg/numbered_list.svg"
import HTMLIcon from "../icons/wysiwyg/html.svg"
import LinkIcon from "../icons/wysiwyg/link.svg"

export default class WysiwygController extends Controller {
  static targets = ['editor', 'toolbar']

  get config() {
    return { ...config.wysiwygs, toolbar: this.toolbarTarget }
  }

  get iframe() {
    return this.element.querySelector('iframe')
  }

  connect() {
    this.editor = new Editor(this.editorTarget, this.config)
    this.editor.on("load", this.setup)
  }

  disconnect() {
    this.iframe.remove()
  }

  announce() {
    const event = new Event("wysiwygs:input")

    this.editor.dispatchEvent(event)
  }

  setup() {
    const { contentDocument: { body } } = this.iframe
    const toolbar = ToolbarTemplate({
      BoldIcon, ItalicIcon, UnderlineIcon, BulletedListIcon,
      NumberedListIcon, HTMLIcon, LinkIcon, ExpandMoreIcon,
      I18n
    })

    this.iframe.classList.add('wysiwyg__iframe')
    body.addEventListener("input", this.announce.bind(this))
    this.editor.insertAdjacentHTML("afterbegin", toolbar)
  }
}
