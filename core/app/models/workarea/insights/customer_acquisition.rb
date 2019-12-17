module Workarea
  module Insights
    class CustomerAcquisition < Base
      class << self
        def dashboards
          %w(people marketing)
        end

        def generate_monthly!
          aggregation_results = find_results

          results = Array.new(days_last_month) do |i|
            result = aggregation_results.detect { |r| r['_id']['day'] == i + 1 } || {}

            {
              new_customers: result['new_customers'] || 0,
              date: Time.zone.local(
                beginning_of_last_month.year,
                beginning_of_last_month.month,
                i + 1
              )
            }
          end

          create!(results: results) if results.present?
        end

        def days_last_month
          (end_of_last_month.to_date - beginning_of_last_month.to_date).to_i + 1
        end

        def find_results
          Metrics::User.collection.aggregate([filter_date_range, group_by_time]).to_a
        end

        def filter_date_range
          {
            '$match' => {
              'first_order_at' => {
                '$gte' => beginning_of_last_month.utc,
                '$lte' => end_of_last_month.utc
              }
            }
          }
        end

        def group_by_time
          {
            '$group' => {
              '_id' => {
                'year' => { '$year' => first_order_at_in_time_zone },
                'month' => { '$month' => first_order_at_in_time_zone },
                'day' => { '$dayOfMonth' => first_order_at_in_time_zone }
              },
              'new_customers' => { '$sum' => 1 }
            }
          }
        end

        def first_order_at_in_time_zone
          { 'date' => '$first_order_at', 'timezone' => Time.zone.tzinfo.name }
        end
      end
    end
  end
end
