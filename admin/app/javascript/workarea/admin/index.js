import { Engine } from "workarea"

export default class Admin extends Engine {
    get context() {
        return require.context
    }

    get namespace() {
        return "workarea/admin"
    }
}
