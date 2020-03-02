require 'active_support/testing/time_helpers'

module Workarea
  class InsightsSeeds
    include ActiveSupport::Testing::TimeHelpers

    def perform
      puts 'Adding insights...'

      add_views
      add_searches
      add_orders

      process
    end

    def add_views
      Catalog::Product.limit(100).pluck(:id).each do |id|
        12.times do |weeks|
          travel_to weeks.weeks.ago
          rand(10).times { Metrics::ProductByDay.inc(key: { product_id: id }, views: 10) }
          travel_back
        end
      end

      Catalog::Category.limit(100).pluck(:id).each do |id|
        12.times do |weeks|
          travel_to weeks.weeks.ago
          rand(10).times { Metrics::CategoryByDay.inc(key: { category_id: id }, views: 10) }
          travel_back
        end
      end
    end

    def add_searches
      terms = Catalog::Product
        .asc(:name)
        .limit(20)
        .flat_map { |product| product.name.split(' ') }
        .uniq

      terms.each do |term|
        12.times do |weeks|
          travel_to weeks.weeks.ago

          rand(3).times { Metrics::SearchByDay.save_search(term, 0) }
          rand(3).times do
            Metrics::SearchByDay.save_search(term, rand(100))
          end

          travel_back
        end
      end
    end

    def add_orders
      Order.all.each_by(1000) { |order| SaveOrderMetrics.perform(order) }
    end

    def process
      add_previous_week_insights
      add_previous_month_insights

      ProcessProductRecommendations.new.perform
      GenerateInsights.generate_all!
    end

    def add_previous_week_insights
      (1...12).each do |weeks|
        travel_to weeks.weeks.ago

        GenerateInsights.generate_weekly_insights

        travel_back
      end
    end

    def add_previous_month_insights
      (1...3).each do |months|
        travel_to months.months.ago

        GenerateInsights.generate_monthly_insights

        travel_back
      end
    end
  end
end
