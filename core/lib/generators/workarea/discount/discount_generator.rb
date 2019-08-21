module Workarea
  # Generates a new +Workarea::Pricing::Discount+ class
  class DiscountGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def copy_model
      template(
        'model.rb.erb',
        "app/models/workarea/pricing/discount/#{file_name}.rb"
      )
      template(
        'model_test.rb.erb',
        "test/models/workarea/pricing/discount/#{file_name}_test.rb"
      )
    end

    def copy_view_model
      template(
        'view_model.rb.erb',
        "app/view_models/workarea/admin/discounts/#{file_name}_view_model.rb"
      )
      template(
        'view_model_test.rb.erb',
        "test/view_models/workarea/admin/discounts/#{file_name}_view_model_test.rb"
      )
    end

    def copy_views
      template(
        'partial.html.haml',
        "app/views/workarea/admin/pricing_discounts/properties/_#{file_name}.html.haml"
      )
    end

    def copy_select_type_partial
      template(
        'select_type_partial.rb.erb',
        "app/views/workarea/admin/create_pricing_discounts/_#{file_name}.html.haml"
      )

      relative_file_path = "workarea/admin/create_pricing_discounts/#{file_name}"

      append_to_file 'config/initializers/workarea.rb' do
        "\nWorkarea::Plugin.append_partials('admin.create_pricing_discounts.setup', '#{relative_file_path}')\n"
      end
    end
  end
end
