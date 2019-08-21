module Workarea
  module Factories
    module Insights
      Factories.add(self)

      def create_hot_products(overrides = {})
        attributes = factory_defaults(:hot_products).merge(overrides)
        Workarea::Insights::HotProducts.create!(attributes)
      end

      def create_cold_products(overrides = {})
        attributes = factory_defaults(:cold_products).merge(overrides)
        Workarea::Insights::ColdProducts.create!(attributes)
      end

      def create_top_products(overrides = {})
        attributes = factory_defaults(:top_products).merge(overrides)
        Workarea::Insights::TopProducts.create!(attributes)
      end

      def create_trending_products(overrides = {})
        attributes = factory_defaults(:trending_products).merge(overrides)
        Workarea::Insights::TrendingProducts.create!(attributes)
      end

      def create_top_discounts(overrides = {})
        attributes = factory_defaults(:top_discounts).merge(overrides)
        Workarea::Insights::TopDiscounts.create!(attributes)
      end
    end
  end
end
