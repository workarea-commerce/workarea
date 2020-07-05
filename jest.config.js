const { defaults } = require('jest-config')

module.exports = {
  moduleFileExtensions: [...defaults.moduleFileExtensions, 'ejs', 'erb'],
  transform: {
    "\\.erb$": "<rootDir>/testing/src/jest-erb-transformer.js",
    "\\.ejs$": "jest-ejs-transformer",
    "\\.js$": "babel-jest"
  },
  setupFiles: [
    "./testing/src/jest-setup.js"
  ]
}
