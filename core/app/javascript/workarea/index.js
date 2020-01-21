import { Application } from "stimulus"
import { definitionsFromContext } from "stimulus/webpack-helpers"
import config from "./config"

/**
 * The Workarea Commerce Platform
 */
const Workarea = {
  /**
   * The Stimulus `Application`, which holds references to all the
   * controllers and routes events appropriately.
   */
  application: Application.start(),

  /**
   * Application configuration, typically supplied via `.config.js.erb`
   * files.
   */
  config,

  /**
   * Load a `require.context` into the application using Stimulus
   * Webpack helpers.
   */
  load(context) {
    this.application.load(definitionsFromContext(context))
  }
}

const base = require.context("workarea/controllers", true, /_controller\.js$/)

Workarea.load(base)

export default Workarea
