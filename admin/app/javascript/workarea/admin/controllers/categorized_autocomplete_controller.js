import { Controller } from "stimulus"
import admin from "../routes.js.erb"
import Turbolinks from "turbolinks"
import $ from "jquery"
import "jquery-ui"
import "../widgets/categorized_autocomplete_widget"

export default class CategorizedAutocompleteController extends Controller {
  static targets = ['field']

  get config() {
    const defaults = {
      source: this.getSource.bind(this),
      select: this.openSelected.bind(this),
      position: {
        my: 'center top',
        at: 'center bottom',
        collision: 'none'
      }
    }
    const { config: { categorizedAutocomplete: { uiOptions } } } = this.app

    return { ...defaults, ...uiOptions }
  }

  getSource({ term: q }, response) {
    $.getJSON(admin.jumpToPath(), { q }, ({ results }) => response(results))
  }

  openSelected(event, ui) {
    const adminToolbar = event.target.closest('.admin-toolbar')

    if (!adminToolbar) {
      Turbolinks.visit(ui.item.url)
    } else {
      window.top.location.href = ui.item.url
    }
  }

  /**
   * Apply the categorizedAutocomplete jQuery UI widget to the <input>
   * element.
   */
  connect() {
    $(this.fieldTarget).categorizedAutocomplete(this.config)
  }
}
