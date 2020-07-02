import { Engine } from "workarea"

export default class Storefront extends Engine {
    get context() {
        return require.context
    }

    get namespace() {
        return "workarea/storefront"
    }
}
