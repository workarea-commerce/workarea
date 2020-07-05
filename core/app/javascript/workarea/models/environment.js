import isObject from "lodash.isobject"

class Environment {
  constructor() {
    this.selector = 'meta[property="environment"]'
    this.attribute = 'content'
  }

  get element() {
    return document.querySelector(this.selector)
  }

  get name() {
    return this.element.getAttribute(this.attribute)
  }

  get isTest() {
    return this.name === 'test' || isObject(window.Teaspoon)
  }

  get isQA() {
    return this.name === 'qa'
  }

  get isDevelopment() {
    return this.name === 'development'
  }

  get isStaging() {
    return this.name === 'staging'
  }

  get isProduction() {
    return this.name === 'production'
  }
}

export default new Environment()
