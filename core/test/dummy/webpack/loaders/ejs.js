module.exports = {
  test: /\.ejs$/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: ['ejs-compiled-loader']
}
