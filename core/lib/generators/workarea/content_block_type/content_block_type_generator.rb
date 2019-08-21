module Workarea
  class ContentBlockTypeGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    class_option 'skip-view-model', type: :boolean

    def create_storefront_view
      template 'storefront_view.html.haml.erb', view_path
    end

    def create_stylesheet
      relative_file_path = "workarea/storefront/components/_#{file_name}_block"
      absolute_file_path = "app/assets/stylesheets/#{relative_file_path}.scss"
      template 'stylesheet.scss.erb', absolute_file_path

      append_to_file 'config/initializers/workarea.rb' do
        "\nWorkarea::Plugin.append_stylesheets('storefront.components', '#{relative_file_path}')\n"
      end
    end

    def create_block_icon
      file_path = "app/assets/images/workarea/admin/content_block_types/#{file_name}.svg"
      template('block.svg', file_path)
    end

    def create_view_model
      return if options['skip-view-model']
      file_path = "app/view_models/workarea/storefront/content_blocks/#{file_name}_view_model.rb"
      template('view_model.rb.erb', file_path)
    end

    def update_configuration
      unless File.exist?("#{destination_root}/#{initializer_path}")
        template('initializer.rb', initializer_path)
      end

      inject_into_file initializer_path, configuration, before: "\nend"
    end

    private

    def dom_class_name
      file_name.dasherize + '-content-block'
    end

    def block_name
      name.titleize
    end

    def view_path
      "app/views/workarea/storefront/content_blocks/_#{file_name}.html.haml"
    end

    def initializer_path
      'config/initializers/workarea_content_block_types.rb'
    end

    def configuration
      <<-RUBY

  block_type '#{block_name}' do
    tags %w(text) # TODO: Update Tags
    description 'TODO: add description'

    # TODO: add fields
    # field 'Text', :text, default: ""
  end
      RUBY
    end
  end
end
