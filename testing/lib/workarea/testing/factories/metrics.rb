module Workarea
  module Factories
    module Metrics
      Factories.add(self)

      mattr_accessor :product_by_week_count, :search_by_week_count
      self.product_by_week_count = 0
      self.search_by_week_count = 0

      def create_product_by_week(overrides = {})
        attributes = factory_defaults(:insights_product_by_week).merge(overrides)
        Workarea::Metrics::ProductByWeek.create!(attributes).tap do
          Factories::Metrics.product_by_week_count += 1
        end
      end

      def create_search_by_week(overrides = {})
        attributes = factory_defaults(:insights_search_by_week).merge(overrides)
        attributes[:query_id] ||= QueryString.new(attributes[:query_string]).id

        Workarea::Metrics::SearchByWeek.create!(attributes).tap do
          Factories::Metrics.search_by_week_count += 1
        end
      end
    end
  end
end
