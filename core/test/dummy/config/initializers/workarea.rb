Workarea.configure do |config|
  config.site_name = 'Workarea Core'
  config.host = 'www.example.com'
  config.asset_store = :file_system, {
    root_path: '/tmp/workarea_core',
    server_root: '/tmp/workarea_core'
  }
end
