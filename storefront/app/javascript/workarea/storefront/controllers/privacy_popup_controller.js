import { Controller } from 'stimulus'
import Cookie from 'js-cookie'
import Dialog from './dialog_controller'
import routes from "../routes.js.erb"

export default class PrivacyPopup extends Controller {
  connect() {
    if (this.shouldShowPopup) {
      this.showPopup()
    }
  }

  get shouldShowPopup() {
    return !this.userHasSeenPopup && !this.isOnPrivacyPolicyPage
  }

  get userHasSeenPopup() {
    return Boolean(Cookie.get('cookies_accepted'))
  }

  get title() {
    return this.data.get('title') || 'Privacy Policy'
  }

  get type() {
    return 'modal'
  }

  isOnPrivacyPolicyPage() {
    return window.location.pathname === routes.pagePath({ id: 'privacy-policy' })
  }

  markUserHasSeenPopup() {
    Cookie.set('cookies_accepted', 'true', 999)
  }

  showPopup() {
    const dialog = Dialog.createElement(
      this.title,
      this.element.innerHTML,
      this.type
    )

    dialog.addEventListener('click', this.markUserHasSeenPopup)
    document.body.append(dialog)
  }
}
