Workarea.configure do |config|
  ns = ENV['WORKAREA_AGENT_NS'].to_s.strip
  config.site_name = ['Workarea Store Front', (ns.presence)].compact.join(' ')

  config.host = 'www.example.com'
  config.asset_store = :file_system, {
    root_path: '/tmp/workarea_storefront',
    server_root: '/tmp/workarea_storefront'
  }
end
