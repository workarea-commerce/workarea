/**
 * Process EJS templates in Jest, since it doesn't use Webpack.
 */

const loader = require('ejs-loader')

module.exports = {
  process(src) {
    return loader(src)
  }
}
