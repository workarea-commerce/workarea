/**
 * An analytics adapter. Subclass to provide your own functionality as
 * defined methods on the adapter.
 */
export default class Analytics {
  constructor(config) {
    this.config = config
  }

  send(event, payload = {}) {
    if (this.hasOwnProperty(event)) {
      this[event].apply(this[event], payload)
    }
  }
}
