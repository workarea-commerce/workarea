module Workarea
  class JsAdapterGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    desc File.read(File.expand_path('../USAGE', __FILE__))

    class_option :engine, type: :string, default: 'storefront', desc: 'The engine in which the JS adapter will be used'

    def generate_module
      template 'js_adapter.js.erb', adapter_file_path
    end

    protected

    def adapter_name
      name.camelize(:lower)
    end

    private

    def adapter_file_path
      "app/assets/javascripts/workarea/#{asset_path}.js"
    end

    def asset_path
      "#{options.engine}/adapters/#{file_path}"
    end
  end
end
