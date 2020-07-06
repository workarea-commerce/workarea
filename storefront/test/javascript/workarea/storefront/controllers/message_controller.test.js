import { Application } from 'stimulus'
import MessageController from '@workarea/storefront/workarea/storefront/controllers/message_controller'

describe('MessageController', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <div class="message message--alert" data-controller="message">
        <a id="close" href="#close" data-action="click->message#close">
          &times;
        </a>
      </form>
    `

    const app = Application.start()

    app.register('message', MessageController)
  })

  it('closes message when button is clicked', () => {
    const close = document.getElementById('close')

    close.click()

    const message = document.querySelector('.message')

    expect(message).toBeNull()
  })
})
