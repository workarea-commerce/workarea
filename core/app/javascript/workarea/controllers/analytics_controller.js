import { Controller } from "stimulus"
import { analytics as config } from "../config"

export default class extends Controller {
  initialize() {
    this.disabled = document.querySelector('meta[property=analytics]')
                            .getAttribute('content') === 'disable'
  }

  /**
   * Bind the click() and submit() DOM events to analytics events if
   * available, and fire the impression analytics event immediately.
   */
  connect() {
    this.adapters = config.adapters.map(Adapter => new Adapter(config))

    if (this.data.has("click")) {
      this.element.addEventListener("click", this.click)
    }

    if (this.data.has("submit")) {
      this.element.addEventListener("submit", this.submit)
    }

    if (this.data.has("impression")) {
      const { event } = this.data.get("impression")

      if (event === "productList") { this.setupProductList() }
      this.send(this.data.get("impression"))
    }
  }

  calculateListPosition(position, page, perPage) {
    position = position || 0;
    page = page || 1;
    perPage = perPage || 20;

    return position + ((page - 1) * perPage);
  }

  setupProductList() {
    const { event, payload } = this.data.get("impression")
    const page = payload.page
    const perPage = payload.per_page
    const attribute = 'data-analytics-impression'
    const selector = `[${attribute}]`
    let index = 0
    const elements = this.element.querySelectorAll(selector)
    const impressions = elements.map(element => {
      const impression = JSON.parse(element.getAttribute(attribute))
      index += 1

      impression.position = this.calculateListPosition(index, page, perPage)

      return impression
    })

    if (isEmpty(impressions)) { return }

    payload.name = payload.name || getBreadcrumbs();
    payload.impressions = impressions;

    this.data.set("impression", { event, payload })
  }

  send(data) {
    if (this.disabled) { return }

    const { payload } = this.data.get(event)

    this.adapters.forEach(adapter => adapter.send(event, payload))
  }

  click(event) {
    const closestList = this.element.parent.closest('[data-controller=analytics]')
      .filter(element => {
        const data = JSON.parse(element.getAttribute("data-analytics-impression"))

        return data.event === "productList"
      })
    const listData = JSON.parse(closestList.getAttribute("data-analytics-impression"))
    const { payload } = JSON.parse(this.data.get("click"))
    const impressions = closestList.querySelectorAll("[data-analytics-impression]")
    const thisImpression = impressions.filter(impression => impression === this.element)
    const position = this.calculateListPosition(
      impressions.index(thisImpression), listData.page, listData.per_page
    )

    payload.list = listData.name || this.getBreadcrumbs()
    payload.position = position

    if (config.preventDomEvents) { event.preventDefault() }

    this.send('productClick', data)
  }

  submit(e) {
    const { event, payload } = this.data.get("submit")

    if (config.preventDomEvents) { e.preventDefault() }

    if (event === 'addToCart') {
      payload.quantity = this.element.querySelector('[name=quantity]')
                                     .getAttribute("value")
    }

    this.send(event, payload)
  }
}
