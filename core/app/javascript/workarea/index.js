import Application from "./application"
import Core from "./core"
import Engine from "./engine"
import I18n from "./i18n"

/**
 * Main export, this is what you get when you `import Workarea from "workarea"`.
 *
 * It can be destructured when imported to grab any individual
 * classes exported here, such as `import { Application } from "workarea"`.
 *
 * This is merely a convenience so one doesn't have to remember the
 * location when `import`-ing base classes from Workarea's JavaScript
 * framework.
 */
export default { Application, Core, Engine, I18n }
