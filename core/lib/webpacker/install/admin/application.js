import { Application } from "workarea"
import Admin from "@workarea/admin"
// Import plugins here with: import Plugin from "workarea/plugin"

const App = new Application("admin")

App.use(Admin)
// Add other plugins here with: App.use(Plugin)

export default App
