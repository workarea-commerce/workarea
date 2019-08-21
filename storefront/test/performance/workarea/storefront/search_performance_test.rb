require 'test_helper'

module Workarea
  module Storefront
    class SearchPerformanceTest < Workarea::PerformanceTest

      setup :setup_catalog

      def setup_catalog
        name_prefix = %w(foo bar foobar)
        Sidekiq::Callbacks.disable do
          @products =
            Array.new(Workarea.config.per_page) do |i|
              create_complex_product(name: "#{name_prefix[i % 3]} #{i}")
            end
        end

        BulkIndexProducts.perform_by_models(@products)
      end

      def test_search_with_complex_products
        get storefront.search_path(q: 'foo')
        assert(response.ok?)
      end
    end
  end
end
