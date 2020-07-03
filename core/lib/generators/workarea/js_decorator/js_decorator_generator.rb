require 'rails/generators'

module Workarea
  class JsDecoratorGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :path, required: true

    def generate_decorator_file
      original_path = find_existing_file(path)

      if original_path.present?
        template 'controller.js.erb', decorator_path
      else
        warn "No file found at #{path}"
      end
    end

    private

    def controller
      name.camelize
    end

    def section
      path.sub('app/javascript/workarea', '').split('/').first
    end

    def name
      File.basename(path, '.js')
    end

    def find_existing_file(source_path)
      workarea_plugin_paths
        .map { |plugin_root| File.join(plugin_root, source_path) }
        .detect { |path| File.exists?(path) }
    end

    def workarea_plugin_paths
      [Workarea::Core::Engine.root] + Workarea::Plugin.installed.map(&:root)
    end

    def file_path
      path.sub(/\A(?:app|test)\//, '')
    end

    def decorating_test?
      path.start_with?('test')
    end

    def decorator_path
      "app/javascript/#{section}/controllers/#{name}.js"
    end

    def decorator_template
      decorating_test? ? 'test_decorator.rb.erb' : 'decorator.rb.erb'
    end

    def test_path
      File.join('test', file_path.sub(rb_regex, '_test.rb'))
    end

    def class_name
      @class_name ||= file_path.split('/workarea/').last.sub(rb_regex, '').camelize
    end

    def test_class_name
      decorating_test? ? class_name : "#{class_name}Test"
    end

    def rb_regex
      /\.rb\z/
    end

    def app_name
      File.basename(Rails.root)
    end
  end
end
