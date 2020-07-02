Workarea.configure do |config|
  config.site_name = 'Workarea Store Front'
  config.host = 'www.example.com'
  config.asset_store = :file_system, {
    root_path: '/tmp/workarea_storefront',
    server_root: '/tmp/workarea_storefront'
  }

  # Disable legacy modules that have been rewritten in base so tests
  # will be run on the rewritten code
  config.legacy_javascript.storefront.modules.delete('workarea/core/modules/form_submitting_controls')
  config.legacy_javascript.storefront.modules.delete('workarea/storefront/modules/messages')
  config.legacy_javascript.storefront.modules.delete('workarea/storefront/modules/dialog')
  config.legacy_javascript.storefront.modules.delete('workarea/storefront/modules/dialog_buttons')
  config.legacy_javascript.storefront.modules.delete('workarea/storefront/modules/dialog_forms')
  config.legacy_javascript.storefront.modules.delete('workarea/storefront/modules/dialog_close_buttons')
  config.legacy_javascript.storefront.modules.delete('workarea/storefront/modules/primary_nav_content')
  config.legacy_javascript.storefront.modules.delete('workarea/storefront/modules/admin_toolbar')
end
