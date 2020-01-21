import Adapter from "../analytics"

/**
 * Test implementation of the analytics adapter
 */
export default class extends Adapter {
  pageView(data = {}) {
    console.log('Workarea.Analytics#pageView', data)
  }

  categoryView(data = {}) {
    console.log('Workarea.Analytics#categoryView', data)
  }
}
