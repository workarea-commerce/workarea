require 'test_helper'

module Workarea
  class AdminSearchQueryWrapperTest < TestCase
    def test_global_id
      query = AdminSearchQueryWrapper.new(model_type: Workarea::Navigation::Redirect)
      result = GlobalID.find(query.to_global_id)
      assert_equal(Workarea::Navigation::Redirect, result.klass)
    end

    def test_sorting
      a = create_redirect(path: '/a', destination: '/b')
      b = create_redirect(path: '/b', destination: '/a')

      query = AdminSearchQueryWrapper.new(
        model_type: 'Workarea::Navigation::Redirect',
        sort: Sort.path
      )
      assert_equal([a, b], query.results.to_a)

      query = AdminSearchQueryWrapper.new(
        model_type: 'Workarea::Navigation::Redirect',
        sort: Sort.destination
      )
      assert_equal([b, a], query.results.to_a)
    end

    def test_filtering
      a = create_tax_category(rates: [{ percentage: 0.06, country: 'US', region: 'PA' }])
      b = create_tax_category(rates: [{ percentage: 0.07, country: 'US', region: 'NJ' }])

      query = AdminSearchQueryWrapper.new(
        model_type: 'Workarea::Tax::Rate',
        query_params: { category_id: a.id }
      )

      assert_equal(a.rates, query.results.to_a)
    end

    def test_searching
      a = create_redirect(path: '/foo', destination: '/bar')
      b = create_redirect(path: '/baz', destination: '/qux')

      query = AdminSearchQueryWrapper.new(
        model_type: 'Workarea::Navigation::Redirect',
        q: ''
      )

      assert_equal(2, query.results.size)

      query = AdminSearchQueryWrapper.new(
        model_type: 'Workarea::Navigation::Redirect',
        q: 'foo'
      )

      assert_equal(1, query.results.size)
      assert_equal([a], query.results.to_a)
    end

    def test_scroll
      50.times { |i| create_redirect(path: "/#{i}", destination: '/bar') }

      query = AdminSearchQueryWrapper.new(
        model_type: 'Workarea::Navigation::Redirect',
        per_page: 5
      )

      count = 0
      passes = 0
      query.scroll { |results| count += results.size; passes += 1 }
      assert_equal(50, count)
      assert_equal(10, passes)

      query = AdminSearchQueryWrapper.new(
        model_type: 'Workarea::Navigation::Redirect',
        per_page: 500
      )

      count = 0
      passes = 0
      query.scroll { |results| count += results.size; passes += 1 }
      assert_equal(50, count)
      assert_equal(1, passes)
    end
  end
end
