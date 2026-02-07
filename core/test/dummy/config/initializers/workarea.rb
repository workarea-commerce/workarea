Workarea.configure do |config|
  ns = ENV['WORKAREA_AGENT_NS'].to_s.strip
  config.site_name = ['Workarea Core', (ns.presence)].compact.join(' ')

  config.host = 'www.example.com'
  config.asset_store = :file_system, {
    root_path: '/tmp/workarea_core',
    server_root: '/tmp/workarea_core'
  }
end
