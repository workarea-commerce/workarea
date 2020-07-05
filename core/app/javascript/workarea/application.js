import { Application as Stimulus } from "stimulus"
import Engine from "./engine"

/**
 * The top-level application object provides an API for describing which
 * engines you wish to include, as well as how to configure the main
 * application. An Application extends the Engine class because it
 * includes many of the same APIs for finding controller definitions.
 */
export default class Application extends Engine {
  constructor(namespace) {
    super()

    this.namespace = namespace
    this.engines = []
    this.stimulus = Stimulus.start()
    this.configurator = () => {}
  }

  /**
   * Configuration for this application, defined by each engine's
   * `configure()` method as well as the current application's
   * `configure()` method.
   */
  get config() {
    let config = {}

    this.engines.forEach(engine => engine.configure(config))
    this.configurator(config)

    return config
  }

  configure(configurator) {
    this.configurator = configurator
  }

  /**
    * Include the controllers and configuration from an existing
    * Workarea engine into this application.
    */
  use(Engine) {
    const engine = new Engine(this)

    this.engines.push(engine)
  }

  /**
   * Load the controllers from a given Engine instance into the Stimulus
   * application.
   */
  load(engine) {
    if (!engine && !engine.controllers) {
      throw new Error(`Engine ${engine} could not be loaded`)
    }

    this.stimulus.load(engine.controllers)
  }

  /**
   * Start the application by setting the host app's `require.context` and loading
   * controllers, first from all engines and then the
   * overridden/additional controllers within this host application.
   */
  run(context) {
    this.context = context

    window.feature.testAll()
    this.engines.forEach(engine => this.load(engine))
    this.load(this)
  }
}
