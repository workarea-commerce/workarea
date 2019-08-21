Workarea.configure do |config|
  config.site_name = 'Workarea Store Front'
  config.host = 'www.example.com'
  config.asset_store = :file_system, {
    root_path: '/tmp/workarea_storefront',
    server_root: '/tmp/workarea_storefront'
  }
end
