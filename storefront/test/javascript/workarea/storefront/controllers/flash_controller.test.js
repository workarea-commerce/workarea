import { Application } from 'stimulus'
import FlashController from '../../../../../app/javascript/workarea/storefront/controllers/flash_controller'

describe('FlashController', () => {
  beforeEach(async () => {
    document.body.innerHTML = `<div data-controller="flash" data-action="ajax:complete@document->flash#render"></div>`
    const app = await Application.start()

    await app.register('flash', FlashController)
  })

  it('renders flash message on ajax:complete', () => {
    const xhr = { getResponseHeader: () => JSON.stringify([["notice", "foo"]]) }
    const detail = [ xhr ]
    const event = new CustomEvent('ajax:complete', { detail })

    document.dispatchEvent(event)

    const message = document.querySelector('.message')

    expect(message).not.toBeNull()
    expect(message.classList.contains('message--notice')).toBe(true)

    const text = message.querySelector('.message__text')
    const button = text.querySelector('.message__dismiss-button')

    expect(text).not.toBeNull()
    expect(button).not.toBeNull()
    expect(text.innerHTML).toMatch('foo')
  })
})
