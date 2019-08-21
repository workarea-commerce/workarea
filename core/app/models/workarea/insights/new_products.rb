module Workarea
  module Insights
    class NewProducts < Base
      class << self
        def dashboards
          %w(catalog)
        end

        def generate_daily!
          results = generate_results
          create!(results: results) if results.present?
        end

        def generate_results
          Catalog::Product
            .where(:created_at.gte => beginning_of_yesteday)
            .where(:created_at.lte => end_of_yesterday)
            .order(created_at: :desc)
            .limit(Workarea.config.insights_products_list_max_results)
            .map { |result| { product_id: result['_id'] } }
        end

        def beginning_of_yesteday
          Time.current.yesterday.beginning_of_day
        end

        def end_of_yesterday
          Time.current.yesterday.end_of_day
        end
      end
    end
  end
end
