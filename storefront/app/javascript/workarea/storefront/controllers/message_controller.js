import { Controller } from "stimulus"

/**
 * This is the "original" MessageController from base, which gets
 * subclassed in the application's storefront JavaScript.
 */
export default class extends Controller {
  close() {
    this.element.remove()
  }
}
