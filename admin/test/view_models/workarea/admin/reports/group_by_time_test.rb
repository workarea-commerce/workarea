require 'test_helper'

module Workarea
  module Admin
    module Reports
      class GroupByTimeTest < TestCase
        def test_get_period_for
          view_model = SalesOverTimeViewModel.new
          assert_equal('2017', view_model.get_period_for('year' => 2017))
          assert_equal('2018-11', view_model.get_period_for('year' => 2018, 'month' => 11))
          assert_equal('2018-10-29', view_model.get_period_for('year' => 2018, 'week' => 44))
          assert_equal('Saturday', view_model.get_period_for('day_of_week' => 7))
          assert_equal('2018-4-1', view_model.get_period_for('year' => 2018, 'month' => 4, 'day' => 1))
        end

        def test_uneven_day_distribution
          report = Workarea::Reports::SalesOverTime.new(starts_at: '2018-11-20', ends_at: '2018-11-28')
          view_model = SalesOverTimeViewModel.wrap(report)
          assert(view_model.uneven_day_distribution?)

          report = Workarea::Reports::SalesOverTime.new(starts_at: '2018-11-21', ends_at: '2018-11-28')
          view_model = SalesOverTimeViewModel.wrap(report)
          refute(view_model.uneven_day_distribution?)

          report = Workarea::Reports::SalesOverTime.new(starts_at: '2018-11-22', ends_at: '2018-11-28')
          view_model = SalesOverTimeViewModel.wrap(report)
          assert(view_model.uneven_day_distribution?)
        end
      end
    end
  end
end
