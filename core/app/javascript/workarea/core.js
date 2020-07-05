import Engine from "./engine"
import TestAdapter from "./models/analytics/test_adapter"

export default class Core extends Engine {
  get require() {
    return require.context
  }

  get namespace() {
    return "workarea"
  }

  configure(config) {
    config.date = {
      format: '%Y-%m-%d %I:%M %P %:z',
      formatDate: '%Y-%m-%d',
      hours: '%I',
      minutes: '%M',
      ampm: '%P'
    }

    config.categorizedAutocompleteFields = {
      uiOptions: {
        minLength: 2
      }
    }

    config.deletion = {
      message: 'Are you sure you want to delete this?'
    }

    config.imageFileExtensions = ['jpg', 'jpeg', 'gif', 'png']

    config.autosubmit = {
      changeDelay: 500,
      inputDelay: 1000
    }

    config.analytics = {
      adapters: [TestAdapter]
    }
  }
}
