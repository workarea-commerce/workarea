module Workarea
  module Generators
    class JsModuleGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)
      desc File.read(File.expand_path('../USAGE', __FILE__))

      class_option :engine, type: :string, default: 'storefront', desc: 'The engine in which the JS module will be used'

      def generate_module
        template 'js_module.js.erb', module_file_path
      end

      protected

      def module_name
        name.camelize(:lower)
      end

      private

      def module_file_path
        "app/assets/javascripts/workarea/#{asset_path}.js"
      end

      def asset_path
        "#{options.engine}/modules/#{file_path}"
      end
    end
  end
end
