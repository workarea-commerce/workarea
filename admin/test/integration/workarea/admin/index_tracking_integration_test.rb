require 'test_helper'

module Workarea
  module Admin
    class IndexTrackingIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_track_index_filters
        get admin.pricing_skus_path

        assert_equal(admin.pricing_skus_path, session[:last_index_path])
        assert_no_changes -> { session[:last_index_path] } do
          get admin.catalog_products_path(format: :json)
        end
        assert_no_changes -> { session[:last_index_path] } do
          get admin.catalog_products_path, xhr: true
        end
      end
    end
  end
end
