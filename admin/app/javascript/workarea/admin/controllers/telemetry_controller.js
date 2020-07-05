import { Controller } from "stimulus"

export default class TelemetryController extends Controller {
  connect() {
    const { ga, location } = window

    if (typeof ga === 'function') {
      ga('set', 'location', location.toString())
      ga('send', 'pageview')
    }
  }
}
