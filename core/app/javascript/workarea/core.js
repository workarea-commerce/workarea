import Engine from "./engine"

export default class Core extends Engine {
    get require() {
        return require.context
    }

    get namespace() {
        return "workarea"
    }

    configure(config) {
        config.deletion.message = 'Are you sure you want to delete this?'
    }
}
