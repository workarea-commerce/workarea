require 'test_helper'

module Workarea
  module Search
    class QueryTest < IntegrationTest
      class FooQuery
        include Search::Query
        document Search::Admin

        def body
          { query: { term: { name: 'Foo' } }, size: 2 }
        end
      end

      def test_deserializing
        product = create_product(name: 'Foo')
        results = FooQuery.new.results

        assert_equal(product.id, results.first.id)
        refute(results.first.new_record?)
        refute(results.first.variants.first.new_record?)
      end

      def test_scroll
        5.times { create_product(name: 'Foo') }

        query = FooQuery.new
        count = 0
        passes = 0

        query.scroll do |results|
          count += results.size
          passes += 1

          results.each { |model| assert_equal(Catalog::Product, model.class) }
        end

        assert_equal(5, count)
        assert_equal(3, passes)
      end
    end
  end
end
