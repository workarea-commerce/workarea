module Workarea
  module Insights
    class ProductsPurchasedTogether < Base
      class << self
        def dashboards
          %w(catalog orders)
        end

        def generate_weekly!
          predictor = Recommendation::ProductPredictor.new

          results = top_sellers.map do |top_seller|
            related = predictor.similarities_for(top_seller.product_id)
            top_seller.as_document.merge(related_product_id: related.first)
          end

          results.reject! { |r| r.blank? || r['related_product_id'].blank? }
          create!(results: results) if results.present?
        end

        def top_sellers
          Metrics::ProductByWeek
            .last_week
            .top_sellers
            .limit(Workarea.config.insights_products_list_max_results)
        end
      end
    end
  end
end
