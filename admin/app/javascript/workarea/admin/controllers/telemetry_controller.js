import { Controller } from "stimulus"

export default class Telemetry extends Controller {
  connect() {
    if (typeof window.ga === 'function') {
      window.ga('set', 'location', location.toString())
      window.ga('send', 'pageview')
    }
  }
}
