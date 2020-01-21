import { Controller } from "stimulus"
import routes from "../routes.js.erb"
import "whatwg-fetch"

export default class extends Controller {
  connect() {
    const event = new Event('touchstart.primaryNavContent')
    const testBodyTouch = this.testBodyTouch.bind(this)

    document.addEventListener(event, testBodyTouch)
  }

  async show(event) {
    const target = event.currentTarget
    const id = target.getAttribute("data-primary-nav-content")
    const url = routes.menuPath({ id })
    const response = await fetch(url)
    const item = await response.text()

    target.insertAdjacentHTML("beforeend", item)
  }

  shouldHover(target) {
    return !target.classList.contains('primary-nav__item--hover')
  }

  clearNavHoverState() {
    this.itemTargets.forEach(item => item.classList.remove('primary-nav__item--hover'))
  }

  touch(event) {
    if (this.shouldHover(event.currentTarget)) {
      event.preventDefault()
      this.clearNavHoverState()
      event.currentTarget.classList.add('primary-nav__item--hover')
    }
  }

  testBodyTouch(event) {
    const primaryNav = document.getElementById('navigation')
    const hoverItem = primaryNav.querySelector('.primary-nav__item--hover')
    const navHasHoverState = !_.isEmpty(hoverItem)
    const clickIsOutsideNav = _.isEmpty(event.target.closest(primaryNav))

    if (clickIsOutsideNav && navHasHoverState) {
      this.clearNavHoverState()
    }
  }
}
