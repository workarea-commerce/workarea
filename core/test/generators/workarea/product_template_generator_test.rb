require 'test_helper'
require 'generators/workarea/product_template/product_template_generator'

module Workarea
  class ProductTemplateGeneratorTest < GeneratorTest
    tests Workarea::ProductTemplateGenerator
    destination Dir.mktmpdir

    setup do
      prepare_destination
      FileUtils.mkdir_p "#{destination_root}/config/initializers"
      File.open "#{destination_root}/config/initializers/workarea.rb", 'w' do |file|
        file.write "Workarea.configure do |config|\n\nend"
      end
    end

    def test_generation
      run_generator %w(SpecialProduct)

      assert_file 'config/initializers/workarea.rb' do |initializer|
        assert_match('config.product_templates << :special_product', initializer)
      end

      assert_file 'app/views/workarea/storefront/products/templates/_special_product.html.haml'

      assert_file 'app/view_models/workarea/storefront/product_templates/special_product_view_model.rb' do |view_model|
        assert_match('class SpecialProductViewModel', view_model)
      end
    end

    def test_skipping_view_model
      run_generator %w(SpecialProduct --skip-view-model)
      assert_no_file 'app/view_models/workarea/storefront/product_templates/special_product_view_model.rb'
    end
  end
end
