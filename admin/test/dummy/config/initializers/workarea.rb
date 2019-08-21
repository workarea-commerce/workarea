Workarea.configure do |config|
  config.site_name = 'Workarea Admin 1'
  config.host = 'www.example.com'
  config.asset_store = :file_system, {
    root_path: '/tmp/workarea_admin',
    server_root: '/tmp/workarea_admin'
  }
end
