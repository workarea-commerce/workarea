module Workarea
  module Admin
    module Reports
      class TimelineViewModel < ApplicationViewModel
        include GroupByTime

        def summary
          {
            revenue: summarize(data_for('revenue')),
            orders: summarize(data_for('orders')),
            units_sold: summarize(data_for('units_sold')),
            customers: summarize(data_for('customers')),
            releases: summarize(release_data)
          }
        end

        def graph_data
          {
            labels: grouped_data.keys.reverse,
            datasets: {
              revenue: transform(data_for('revenue')),
              orders: transform(data_for('orders')),
              units_sold: transform(data_for('units_sold')),
              customers: transform(data_for('customers')),
              releases: transform(release_data)
            }
          }
        end

        private

        def grouped_data
          results.group_by(&:starts_at)
        end

        def data_for(type)
          grouped_data.transform_values do |values|
            (values || []).map { |v| v[type] }
          end
        end

        def release_data
          grouped_data.transform_values do |values|
            (values || []).map { |v| count_releases(v.starts_at.to_date) }
          end
        end

        def transform(data)
          data.map { |k, v| Hash[x: k, y: v.first] }.reverse
        end

        def summarize(data)
          data.reduce(0) { |sum, (_k, v)| sum + v.first }
        end

        def releases
          @releases ||= Release.published_between(
            starts_at: starts_at,
            ends_at: ends_at
          ).to_a
        end

        def count_releases(date)
          releases.count { |r| r.published_at.to_date == date }
        end
      end
    end
  end
end
