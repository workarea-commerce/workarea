json.name Workarea.config.site_name
json.short_name Workarea.config.site_name
json.icons(%w(192x192 512x512)) do |size|
  json.src favicons_path(size)
  json.sizes size
  json.type 'image/png'
end
json.theme_color Workarea.config.web_manifest.theme_color
json.background_color Workarea.config.web_manifest.background_color
json.start_url '/?utm_source=homescreen'
json.display Workarea.config.web_manifest.display_mode
