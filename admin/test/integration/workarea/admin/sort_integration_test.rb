require 'test_helper'

module Workarea
  module Admin
    class SortIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_ignores_invalid_sort
        create_product(name: 'Foo')
        create_category(name: 'Foo')

        get admin.search_path(q: 'foo', sort: 'foo')
        assert(response.ok?)
      end
    end
  end
end
