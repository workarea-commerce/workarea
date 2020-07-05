import { Controller } from "stimulus"
import User from "../models/user"
import admin from "workarea/admin/routes.js.erb"

export default class AdminToolbarController extends Controller {
  get shouldDisplay() {
    const user = User.current()

    return user.impersonating
            || user.browsing_as_guest
            || (user.admin && user.logged_in)
  }

  get url() {
    const return_to = window.location.href
    const meta = document.querySelector('meta[property="global-id"]')
    const id = meta.attr('content')

    return admin.toolbarPath({ return_to, id })
  }

  initialize() {
    if (this.shouldDisplay) {
      this.render()
    }
  }

  render() {
    const iframe = document.createElement("iframe")

    iframe.setAttribute("src", this.url)
    iframe.setAttribute("scrolling", "no")
    iframe.setAttribute("id", "admin-toolbar")
    iframe.setAttribute("role", "document")
    iframe.setAttribute("title", "Admin Toolbar")
    iframe.setAttribute("data-controller", "admin_toolbar")
    iframe.setAttribute("data-action", "keyup->admin_toolbar#esc")
    iframe.classList.add("admin-toolbar")

    document.body.prepend(iframe)
  }

  connect() {
    const loaded = new Event("adminToolbar:loaded")

    window.dispatchEvent(loaded)
  }

  collapse() {
    this.element.classList.remove('admin-toolbar--expanded')
    this.headerTarget.classList.remove('header--takeover')
  }

  /**
   * Expand the header past the <iframe>
   */
  expand() {
    const focus = new Event("focus")

    this.element.classList.add('admin-toolbar--expanded')
    this.headerTarget.classList.add('header--takeover')
    this.searchTarget.dispatchEvent(focus)
  }

  /**
   * Collapse when the Esc key is pressed
   */
  esc(event) {
    if (event.keyCode === 27) {
      this.collapse()
    }
  }
}
