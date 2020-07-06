import Core from "@workarea/core"
import Storefront from "@workarea/storefront"
import Admin from "@workarea/admin"

/**
 * The meta-package for Workarea's JS. This allows you to `import` the
 * lower-level components from Workarea without having to think about
 * what module it comes from. It also keeps most application files
 * smaller by providing a "one-line import".
 *
 * @example
 *    import { Application } from "workarea
 *    import { Engine } from "workarea"
 *    import { Application, Admin } from "workarea"
 *    import { Application, Storefront } from "workarea"
 */

export default { ...Core, Storefront, Admin }
