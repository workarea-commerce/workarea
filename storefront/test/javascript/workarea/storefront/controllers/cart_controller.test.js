import { Application } from 'stimulus'
import CartController from '../../../../../app/javascript/workarea/storefront/controllers/cart_controller'

describe('CartController', () => {
  it('appends count to the link if not yet created', async () => {
    document.body.innerHTML = `
      <div id="cart_link">
        <a href="/cart">Cart</a>
      </div>
      <span id="item" data-controller="cart" data-cart-count="1">
        Item
      </span>
    `

    const app = await Application.start()

    await app.register('cart', CartController)

    const link = await document.getElementById('cart_link')
    const count = await link.querySelector('.page-header__cart-count')

    expect(count).not.toBeNull()
    expect(count.innerHTML).toEqual('1')
  })

  it('updates html within the count when already created', async () => {
    document.body.innerHTML = `
      <div id="cart_link">
        <a href="/cart">
          <span class="page-header__cart-count">1</span>
          Cart
        </a>
      </div>
      <span id="item" data-controller="cart" data-cart-count="2">
        Item
      </span>
    `

    const app = await Application.start()

    await app.register('cart', CartController)

    const link = await document.getElementById('cart_link')
    const count = await link.querySelector('.page-header__cart-count')

    expect(count).not.toBeNull()
    expect(count.innerHTML).toEqual('2')
  })
})
