import { Controller } from "stimulus"
import User from "../models/user"

export default class extends Controller {
  get shouldDisplay() {
    const user = User.current()

    return user.impersonating
            || user.browsing_as_guest
            || (user.admin && user.logged_in);
  }

  get url() {
    const params = {
      return_to: window.location.href,
      id: document.querySelector('meta[property="global-id"]')
                  .attr('content')
    };
    const query = Object.keys(params)
                        .map(param => `${param}=${params[param]}`)
                        .join('&')

    return `/admin/toolbar?${query}`
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
    this.element.classList.remove('admin-toolbar--expanded');
    this.headerTarget.classList.remove('header--takeover');
  }

  /**
   * Expand the header past the <iframe>
   */
  expand() {
    const focus = new Event("focus")

    this.element.classList.add('admin-toolbar--expanded');
    this.headerTarget.classList.add('header--takeover');
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
