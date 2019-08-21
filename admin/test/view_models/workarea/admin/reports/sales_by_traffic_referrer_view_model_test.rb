require 'test_helper'

module Workarea
  module Admin
    module Reports
      class SalesByTrafficReferrerViewModelTest < TestCase
        def test_handling_nil_results
          Metrics::TrafficReferrerByDay.create!(orders: 1, reporting_on: Time.current)
          report = Workarea::Reports::SalesByTrafficReferrer.new
          view_model = SalesByTrafficReferrerViewModel.wrap(report)

          assert_equal(1, view_model.results.size)
          assert_nil(view_model.results.first.source)
          assert_nil(view_model.results.first.medium)
        end
      end
    end
  end
end
