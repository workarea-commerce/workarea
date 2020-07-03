if Workarea.config.enable_webpacker && !Rails.root.join('node_modules').exist?
  raise "Error: Cannot start app until you've run `rails workarea:install:packages`"
end
