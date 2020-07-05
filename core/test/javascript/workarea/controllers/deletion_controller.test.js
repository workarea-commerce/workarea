import { Application } from 'stimulus'
import DeletionController from '../../../../app/javascript/workarea/controllers/deletion_controller'

describe('DeletionController', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <form data-controller="deletion" data-action="submit->deletion#submit">
      </form>
    `

    const app = Application.start()

    app.register('deletion', DeletionController)
  })

  it('deletes element when submitted', () => {
    const form = document.querySelector('form')
    const submit = new Event('submit')
    let fired

    ['deletionForm:confirmed', 'deletionForm:canceled'].forEach(name => {
      form.addEventListener(name, event => fired = event.type)
    })

    form.dispatchEvent(submit)
    expect(fired).toEqual('deletionForm:canceled')
  })
})
