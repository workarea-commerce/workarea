/**
 * An analytics adapter. Subclass to provide your own functionality as
 * defined methods on the adapter.
 */
export default class Analytics {
  constructor(config) {
    this.config = config
  }

  handle(event, payload = {}) {
    if (this[event]) {
      this[event].apply(this[event], payload)
    }
  }
}
