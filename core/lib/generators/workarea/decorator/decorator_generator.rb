require 'rails/generators'

module Workarea
  class DecoratorGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    argument :path, required: true

    def generate_decorator_file
      original_path = find_existing_file(path)

      if original_path.present?
        template decorator_template, decorator_path
      else
        warn "No file found at #{path}"
      end
    end

    def copy_related_test_file
      return if decorating_test?
      original_test_path = find_existing_file(test_path)

      if original_test_path.present?
        template 'test_decorator.rb.erb', test_path.sub(rb_regex, '.decorator')
      else
        warn "No tests found for #{decorator_path}"
      end
    end

    private

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
      prefix = decorating_test? ? 'test' : 'app'
      File.join(prefix, file_path.sub(rb_regex, '.decorator'))
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
