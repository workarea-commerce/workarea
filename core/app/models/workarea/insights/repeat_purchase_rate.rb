module Workarea
  module Insights
    class RepeatPurchaseRate < Base
      class << self
        def dashboards
          %w(people orders)
        end

        def generate_monthly!
          results = [30, 60, 90].reduce([]) do |memo, since|
            purchased = customers_who_purchased(since.days.ago)
            purchased_again = customers_who_purchased_again(since.days.ago)

            memo << {
              days_ago: since,
              purchased: purchased,
              purchased_again: purchased_again,
              percent_purchased_again: (purchased_again / purchased.to_f) * 100
            }
          end

          create!(results: results)
        end

        def customers_who_purchased_again(since)
          Metrics::User
            .where(:first_order_at.gte => since)
            .where('$expr' => { '$gt' => ['$last_order_at', '$first_order_at'] })
            .count
        end

        def customers_who_purchased(since)
          Metrics::User.where(:first_order_at.gte => since).count
        end
      end
    end
  end
end
