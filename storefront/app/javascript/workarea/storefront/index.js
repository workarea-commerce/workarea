import { Engine } from "workarea"
import "feature.js"

export default class Storefront extends Engine {
  get context() {
    return require.context
  }

  get namespace() {
    return "workarea/storefront"
  }

  /**
   * Run feature tests as soon as possible.
   */
  initialize() {
    window.feature.testAll()
  }
}
