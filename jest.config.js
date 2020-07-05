const {defaults } = require('jest-config')

module.exports = {
  moduleFileExtensions: [...defaults.moduleFileExtensions, 'ejs'],
  transform: {
    "\\.ejs$": "<rootDir>/testing/src/jest-ejs-transform.js",
    "\\.js$": "babel-jest"
  },
  setupFiles: [
    "./testing/src/jest-setup.js"
  ]
}
