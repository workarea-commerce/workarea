import { Application as Stimulus } from "stimulus"
import Engine from "./engine"
import Core from "./core"

/**
 * The top-level application object provides an API for describing which
 * engines you wish to include, as well as how to configure the main
 * application.
 */
export default class Application extends Engine {
    constructor() {
        super()

        this.engines = []
        this.configurators = [Core.configure]
        this.stimulus = Stimulus.start()
    }

    get config() {
        let config = {}

        this.configurators.forEach(configure => engine.configure(config))

        return config
    }

    configure(configurator) {
        this.configurators.push(configurator)
    }

    use(Engine) {
        const engine = new Engine(this)
        this.configurators.push(engine.configure)
        this.engines.push(engine)
    }

    load(engine) {
        if (engine && engine.controllers) {
            return this.stimulus.load(engine.controllers)
        } else {
            console.error(engine)
            throw new Error("Engine could not be loaded")
        }
    }

    run(context) {
        this.context = context
        this.engines.forEach(engine => this.load(engine))
        this.load(this)
    }
}
