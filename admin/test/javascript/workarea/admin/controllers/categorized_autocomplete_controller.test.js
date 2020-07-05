import { Application } from 'stimulus'
import CategorizedAutocompleteController from '../../../../../app/javascript/workarea/admin/controllers/categorized_autocomplete_controller'

describe('CategorizedAutocompleteController', () => {
  beforeEach(() => {
    document.body.innerHTML = `
      <form data-controller="categorized-autocomplete">
        <input id="input" type="search" name="q" />
      </form>
    `

    const app = Application.start()

    app.register('categorized-autocomplete', CategorizedAutocompleteController)
  })

  it('shows autocomplete when input changes', () => {
    const input = document.getElementById('input')
    input.value = 'foo'
    input.change()

    expect(document.querySelectorAll('.ui-menu-item')).not.toBeEmpty()
  })
})
