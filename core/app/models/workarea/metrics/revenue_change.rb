module Workarea
  module Metrics
    module RevenueChange
      extend ActiveSupport::Concern

      included do
        field :revenue, type: Float, default: 0.0
        field :previous_week_revenue, type: Float, default: 0.0
        field :revenue_change, type: Float, default: 0.0

        index(revenue_change: 1)

        scope :top_sellers, -> { desc(:revenue) }
        scope :improved_revenue, -> { where(:revenue_change.gt => 0) }
        scope :declined_revenue, -> { where(:revenue_change.lt => 0) }
      end

      module ClassMethods
        def revenue_change_median
          sort = if scoped.selector.present? && scoped.selector <= declined_revenue.selector
            :desc
          else
            :asc
          end

          skip = (scoped.count / 2.to_f).floor
          skip = skip < 0 ? 0 : skip
          scoped.order_by(revenue_change: sort).skip(skip).first&.revenue_change.to_i
        end

        def revenue_change_standard_deviation
          grouped = scoped.group(id: nil, result: { '$stdDevPop' => '$revenue_change' })
          results = collection.aggregate(grouped.pipeline).to_a
          results.empty? ? 0 : results.first['result']
        end
      end
    end
  end
end
