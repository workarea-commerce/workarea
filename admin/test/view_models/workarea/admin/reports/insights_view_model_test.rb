require 'test_helper'

module Workarea
  module Admin
    module Reports
      class InsightsViewModelTest < TestCase
        setup :create_insights

        def create_insights
          @hot = create_hot_products
          @cold = create_cold_products
        end

        def test_type_options
          view_model = InsightsViewModel.wrap(nil)
          assert_equal(3, view_model.type_options.size)
          assert(view_model.type_options.include?([t('workarea.admin.reports.insights.all_insights'), nil]))
          assert(view_model.type_options.include?(['Hot Products', @hot.class.name]))
          assert(view_model.type_options.include?(['Cold Products', @cold.class.name]))
        end

        def test_feed
          view_model = InsightsViewModel.wrap(nil)
          assert(view_model.feed.all? { |i| i.is_a?(InsightViewModel) })
          assert_equal([@cold, @hot], view_model.feed.map(&:model))

          view_model = InsightsViewModel.wrap(nil, type: @hot.class.name)
          assert_equal([@hot], view_model.feed.map(&:model))

          view_model = InsightsViewModel.wrap(nil, type: @cold.class.name)
          assert_equal([@cold], view_model.feed.map(&:model))
        end
      end
    end
  end
end
