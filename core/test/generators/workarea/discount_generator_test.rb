require 'test_helper'
require 'generators/workarea/discount/discount_generator'

module Workarea
  class DiscountGeneratorTest < GeneratorTest
    tests Workarea::DiscountGenerator
    destination Dir.mktmpdir

    setup do
      prepare_destination

      # HACK
      # This is a hack to eliminate a meaningless error message.
      FileUtils.mkdir_p("#{destination_root}/bin")
      FileUtils.touch("#{destination_root}/bin/rails")

      FileUtils.mkdir_p "#{destination_root}/config/initializers"
      File.open "#{destination_root}/config/initializers/workarea.rb", 'w' do |file|
        file.write "Workarea.configure do |config|\n\nend"
      end

      run_generator %w(FreePlumbus)
    end

    def test_model
      assert_file 'app/models/workarea/pricing/discount/free_plumbus.rb' do |model|
        assert_match('class FreePlumbus', model)
      end

      assert_file 'test/models/workarea/pricing/discount/free_plumbus_test.rb' do |test|
        assert_match('class FreePlumbusTest', test)
      end
    end

    def test_view_model
      assert_file 'app/view_models/workarea/admin/discounts/free_plumbus_view_model.rb' do |test|
        assert_match('class FreePlumbusViewModel', test)
      end

      assert_file 'test/view_models/workarea/admin/discounts/free_plumbus_view_model_test.rb' do |test|
        assert_match('class FreePlumbusViewModelTest', test)
      end
    end

    def test_views
      assert_file 'app/views/workarea/admin/pricing_discounts/properties/_free_plumbus.html.haml' do |test|
        assert_match('TODO', test)
      end
    end

    def test_assert_select_type_partial
      assert_file 'app/views/workarea/admin/create_pricing_discounts/_free_plumbus.html.haml'
    end

    def test_update_configuration
      assert_file 'config/initializers/workarea.rb' do |config|
        assert_match(
          "Workarea::Plugin.append_partials('admin.create_pricing_discounts.setup', 'workarea/admin/create_pricing_discounts/free_plumbus')",
          config
        )
      end
    end
  end
end
