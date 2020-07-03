module.exports = {
  test: /\.svg/,
  enforce: 'pre',
  exclude: /node_modules/,
  use: [{
    loader: 'svg-inline-loader'
  }]
}
