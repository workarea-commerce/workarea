import Workarea from "../../workarea"
import routes from "./routes"

const controllers = require.context(
  "workarea/admin/controllers", true, /_controller\.js$/
)

export default { controllers, routes }
