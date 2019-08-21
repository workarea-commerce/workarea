require 'test_helper'

module Workarea
  module Storefront
    class PaginationHelperTest < ViewTest
      def request
        @request ||= ActionDispatch::TestRequest.new
      end

      def test_pagination_path_for
        request.path = '/foo'

        result = pagination_path_for(page: 1)
        assert_equal('/foo?page=1', result)

        request.query_parameters[:page] = 1
        result = pagination_path_for(page: 2)
        assert_equal('/foo?page=2', result)

        request.query_parameters[:asdf] = 'blah'
        request.query_parameters[:page] = 1
        result = pagination_path_for(page: 2)
        assert_equal('/foo?asdf=blah&page=2', result)
      end
    end
  end
end
