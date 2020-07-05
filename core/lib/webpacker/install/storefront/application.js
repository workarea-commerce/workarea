import { Application } from "workarea"
import Storefront from "workarea/storefront"
// Import plugins here with: import Plugin from "workarea/plugin"

const App = new Application("storefront")

App.use(Storefront)
// Add other plugins here with: App.use(Plugin)

export default App
