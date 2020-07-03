require "webpacker/configuration"

# This template combines webpacker:install:erb and webpacker:install:stimulus,
# but omits a lot of the boilerplate code meant for completely
# green-field apps. Additionally, we setup loaders for reading EJS
# templates from JS, and importing inline SVG elements.
#
# It's a separate file from the main application template so users who
# wish to upgrade to Webpacker can do so by running a Rake task rather
# than manually going through the steps.

say "Updating webpack paths to include additional file extensions"
insert_into_file Webpacker.config.config_path, "- .erb\n".indent(4), after: /\s+extensions:\n/
insert_into_file Webpacker.config.config_path, "- .ejs\n".indent(4), after: /\s+extensions:\n/
insert_into_file Webpacker.config.config_path, "- .svg\n".indent(4), after: /\s+extensions:\n/

say "Copying loaders to config/webpack/loaders"
copy_file "#{__dir__}/loaders/erb.js", Rails.root.join("config/webpack/loaders/erb.js").to_s
copy_file "#{__dir__}/loaders/ejs.js", Rails.root.join("config/webpack/loaders/ejs.js").to_s
copy_file "#{__dir__}/loaders/svg.js", Rails.root.join("config/webpack/loaders/svg.js").to_s

say "Adding loaders to config/webpack/environment.js"
insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "const ejs = require('./loaders/ejs')\n",
  after: /require\(('|")@rails\/webpacker\1\);?\n/
insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "const erb = require('./loaders/erb')\n",
  after: /require\(('|")@rails\/webpacker\1\);?\n/
insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "const svg = require('./loaders/svg')\n",
  after: /require\(('|")@rails\/webpacker\1\);?\n/

insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "environment.loaders.prepend('ejs', ejs)\n",
  before: "module.exports"
insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "environment.loaders.prepend('erb', erb)\n",
  before: "module.exports"
insert_into_file Rails.root.join("config/webpack/environment.js").to_s,
  "environment.loaders.prepend('svg', svg)\n",
  before: "module.exports"

say "Creating #{Webpacker.config.source_entry_path}"
directory "#{__dir__}/packs", Webpacker.config.source_entry_path

say "Creating admin JS"
directory "#{__dir__}/admin", "#{Webpacker.config.source_path}/admin"

say "Creating storefront JS"
directory "#{__dir__}/storefront", "#{Webpacker.config.source_path}/storefront"

say "Installing all loader dependencies"
yarn add 'rails-erb-loader ejs-compiled-loader svg-inline-loader'

say "Installing Workarea JavaScript dependencies"

say "Webpacker now supports Workarea.js 🎉", :green
