import { Controller } from "stimulus"
import CartCountTemplate from "../templates/cart_count.ejs"

export default class CartController extends Controller {
  get link() {
    return document.querySelector('#cart_link')
  }

  get counter() {
    return this.link.querySelector('.page-header__cart-count')
  }

  connect() {
    const quantity = this.data.get('count')
    const count = CartCountTemplate({ quantity })

    if (this.counter) {
      this.counter.innerHTML = count
    } else {
      this.link.insertAdjacentHTML('beforeend', count)
    }
  }
}
