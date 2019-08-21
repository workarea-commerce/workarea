require 'test_helper'
require 'generators/workarea/decorator/decorator_generator'

module Workarea
  class DecoratorGeneratorTest < GeneratorTest
    tests Workarea::DecoratorGenerator
    destination Dir.mktmpdir

    setup do
      prepare_destination
    end

    def test_decorator
      run_generator %w(app/models/workarea/search/storefront/product.rb)
      assert_file 'app/models/workarea/search/storefront/product.decorator' do |decorator|
        assert_match('decorate Search::Storefront::Product', decorator)
      end
    end

    def test_test_decorator_generation
      run_generator %w(app/models/workarea/search/storefront/product.rb)
      assert_file 'test/models/workarea/search/storefront/product_test.decorator' do |test|
        assert_match("require 'test_helper'", test)
        assert_match('decorate Search::Storefront::ProductTest', test)
      end
    end

    def test_decorating_test
      run_generator %w(test/integration/workarea/authentication_test.rb)
      assert_file 'test/integration/workarea/authentication_test.decorator' do |test|
        assert_match("require 'test_helper'", test)
        assert_match('decorate AuthenticationTest', test)
      end
    end
  end
end
