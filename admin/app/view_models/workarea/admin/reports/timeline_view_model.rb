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

        def releases
          @releases ||= Release.published_between(
            starts_at: starts_at,
            ends_at: ends_at
          ).to_a
        end

        private

        def date_range
          starts_at.to_date..ends_at.to_date
        end

        def grouped_data
          date_range.each_with_object({}) do |date, group|
            group[date] = results.select { |r| r.starts_at.to_date == date }
          end
        end

        def data_for(type)
          grouped_data.transform_values do |values|
            (values || []).map { |v| v[type] }
          end
        end

        def release_data
          date_range.each_with_object({}) do |date, group|
            data = releases.select { |r| r.published_at.to_date == date }
            group[date] = [data.count]
          end
        end

        def transform(data)
          data.map { |k, v| Hash[x: k.to_time, y: v.first] }.reverse
        end

        def summarize(data)
          data
            .select { |_, v| ! v.empty? }
            .reduce(0) { |sum, (_k, v)| sum + v.first }
        end
      end
    end
  end
end
