module Workarea
  class ProductTemplateGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)
    class_option 'skip-view-model', type: :boolean

    def add_template_to_workarea_initializer
      inject_into_file 'config/initializers/workarea.rb', before: "\nend" do
        "\n\n\s\sconfig.product_templates << :#{file_name}"
      end
    end

    def create_partial_template
      target_path = 'app/views/workarea/storefront/products/templates/'
      target_path += "_#{file_name}.html.haml"
      copy_file "#{Storefront::Engine.root}/app/views/workarea/storefront/products/templates/_generic.html.haml", target_path
    end

    def create_view_model
      return if options['skip-view-model']

      target_path = 'app/view_models/workarea/storefront/product_templates/'
      target_path += "#{file_name}_view_model.rb"
      template 'view_model.rb.erb', target_path
    end
  end
end
