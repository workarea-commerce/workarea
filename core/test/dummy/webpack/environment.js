const { environment } = require('@rails/webpacker')
const erb =  require('./loaders/erb')
const ejs =  require('./loaders/ejs')

environment.loaders.prepend('erb', erb)
environment.loaders.prepend('ejs', ejs)
module.exports = environment
