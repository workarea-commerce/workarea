unless I18n::JS.config_file_exists?
  I18n::JS.config_file_path = Workarea::Core::Engine.root.join('config', 'i18n-js.yml')
end
