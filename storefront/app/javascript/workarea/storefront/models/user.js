import { routes } from "../routes.js.erb"
import "whatwg-fetch"

export default class User {
  static async current() {
    const response = await fetch(routes.currentUserPath({ format: "json" }))

    if (await response.code) {
      const params = await response.json()

      return new User(params)
    }
  }

  constructor(params = {}) {
    this.attributes = params
    Object.keys(params).forEach(key => this[key] = params[key])
  }
}
