require 'test_helper'
require 'generators/workarea/seeds/seeds_generator'

module Workarea
  class SeedsGeneratorTest < GeneratorTest
    tests Workarea::SeedsGenerator
    destination Dir.mktmpdir

    setup do
      prepare_destination
      FileUtils.mkdir_p "#{destination_root}/config/initializers"
      File.open "#{destination_root}/config/initializers/workarea.rb", 'w' do |file|
        file.write "Workarea.configure do |config|\n\nend"
      end
    end

    def test_seeds
      run_generator %w(FeaturedProducts)

      assert_file 'app/seeds/workarea/featured_products_seeds.rb' do |creator|
        assert_match('class FeaturedProductsSeeds', creator)
      end

      assert_file 'config/initializers/workarea.rb' do |initializer|
        assert_match("config.seeds << 'Workarea::FeaturedProductsSeeds'", initializer)
      end
    end
  end
end
