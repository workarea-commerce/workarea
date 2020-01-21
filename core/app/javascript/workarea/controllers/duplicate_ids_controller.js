import { Controller } from "stimulus"
import { isTest, isDevelopment } from "../models/environment"
import DuplicateIdsError from "../errors/duplicate_ids_error"

/**
 * Duplicate ID Protection
 */
export default class extends Controller {
  /**
   * An array of all ID attributes on the page.
   */
  get ids() {
    return this.element.querySelectorAll('[id]')
                       .map(element => element.getAttribute('id'))
  }

  /**
   * A unique Set of all IDs in the array.
   */
  get set() {
    return [...new Set(this.ids)]
  }

  /**
   * If the length of the set is equal to the length of the IDs, then
   * the IDs array is a unique array.
   */
  get unique() {
    return this.set.length === this.ids.length
  }

  /**
   * Whether we are running on a local development/test instance of the
   * application. This module does nothing in qa/staging/production
   * environments.
   */
  get local() {
    return isTest || isDevelopment
  }

  /**
   * When the page is rendered, scan for duplicate IDs within it and
   * throw errors when a duplicate is found. Log this error to console
   * if in development mode, and throw it if it's in test mode to stop
   * test execution.
   */
  connect() {
    if (this.unique || !this.local) { return; }

    try {
      throw new DuplicateIdsError(ids)
    } catch(error) {
      if (isTest) {
        throw error
      } else {
        console.error(error.name, error.message)
      }
    }
  }
}
