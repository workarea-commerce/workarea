import { definitionsFromContext } from "stimulus/webpack-helpers"

const CONTROLLER_FILENAMES = /_controller\.js$/

export default class Engine {
    constructor(app = null) {
        this.app = app
    }

    configure(_config) {}

    get routes() {
        return this.require("./routes.js.erb")
    }

    get context() {
        throw new Error("$Engine must provide require.context")
    }

    get namespace() {
        throw new Error("Engine must provide namespace")
    }

    get require() {
        return this.context(this.namespace, true)
    }

    get controllers() {
        return definitionsFromContext(
            this.require.context('controllers', true, CONTROLLER_FILENAMES)
        ).map(Controller => Controller.app = this.app)
    }
}
