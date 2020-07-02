/**
 * An analytics adapter. Subclass to provide your own functionality as
 * defined methods on the adapter.
 */
export default class Analytics {
  constructor(config) {
    this.config = config
  }

  /**
   * Called when the AnalyticsController is connected, useful for
   * setting up your own custom callbacks bound to DOM events.
   */
  initialize(controller) {}

  /**
   * Call a method on this object with the given payload.
   */
  send(event, payload = {}) {
    if (this.hasOwnProperty(event)) {
      this[event].apply(this[event], payload)
    }
  }
}
