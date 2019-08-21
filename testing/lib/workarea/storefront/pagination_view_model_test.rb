module Workarea
  module Storefront
    module PaginationViewModelTest
      def pagination_view_model
        @pagination_view_model ||= pagination_view_model_class.new(
          stub_everything(:model)
        )
      end

      def test_total_pages
        pagination_view_model.expects(:total).returns(2)
        pagination_view_model.expects(:per_page).returns(1)
        assert_equal(2, pagination_view_model.total_pages)

        pagination_view_model.expects(:total).returns(20)
        pagination_view_model.expects(:per_page).returns(15)
        assert_equal(2, pagination_view_model.total_pages)

        pagination_view_model.expects(:total).returns(1)
        pagination_view_model.expects(:per_page).returns(15)
        assert_equal(1, pagination_view_model.total_pages)
      end

      def test_first_page
        pagination_view_model.expects(:page).returns(1)
        assert(pagination_view_model.first_page?)
      end

      def test_last_page
        pagination_view_model.expects(:page).returns(2)
        pagination_view_model.expects(:per_page).returns(15)
        pagination_view_model.expects(:total).returns(30)
        assert(pagination_view_model.last_page?)
      end

      def test_next_page
        pagination_view_model.expects(:per_page).returns(15).at_least_once
        pagination_view_model.expects(:total).returns(30).at_least_once

        pagination_view_model.expects(:page).returns(1).at_least_once
        assert_equal(2, pagination_view_model.next_page)

        pagination_view_model.expects(:page).returns(2).at_least_once
        assert_nil(pagination_view_model.next_page)
      end

      def test_prev_page
        pagination_view_model.expects(:page).returns(1).at_least_once
        assert_nil(pagination_view_model.prev_page)

        pagination_view_model.expects(:page).returns(2).at_least_once
        assert_equal(1, pagination_view_model.prev_page)
      end
    end
  end
end
