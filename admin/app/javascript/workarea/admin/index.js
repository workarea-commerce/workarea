import Workarea from "@workarea/core"
import routes from "./routes"

const controllers = require.context(
  "workarea/admin/controllers", true, /_controller\.js$/
)

export default { controllers, routes }
