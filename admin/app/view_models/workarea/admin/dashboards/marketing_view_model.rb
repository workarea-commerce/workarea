module Workarea
  module Admin
    module Dashboards
      class MarketingViewModel < ApplicationViewModel
        include InsightsGraphs

        add_insights_graphs from: Workarea::Reports::SalesOverTime, on: :discounts

        def traffic_referrer_graph_data
          traffic_referrer_report.results.take(5).reduce({}) do |memo, result|
            memo.merge(result['source'] => result['revenue'])
          end
        end

        def email_signups
          @email_signups ||= Email::Signup
            .by_date(starts_at: starts_at.beginning_of_day, ends_at: ends_at.end_of_day)
            .count
        end

        def email_signups_percent_change
          @email_signups_percent_change ||=
            begin
              first = Email::Signup
                .by_date(starts_at: previous_starts_at.beginning_of_day, ends_at: previous_ends_at.end_of_day)
                .count

              calculate_percent_change(first, email_signups)
            end
        end

        def email_signups_graph_data
          @email_signups_graph_data ||=
            begin
              query = Email::Signup.collection.aggregate(
                [
                  {
                    '$match' => {
                      'created_at' => {
                        '$gte' => starts_at.beginning_of_day.utc,
                        '$lte' => ends_at.end_of_day.utc
                      }
                    }
                  },
                  {
                    '$group' => {
                      '_id' => {
                        'day' => { '$dayOfMonth' => created_at_in_time_zone },
                        'month' => { '$month' => created_at_in_time_zone },
                        'year' => { '$year' => created_at_in_time_zone }
                      },
                      'created_at' => { '$first' => '$created_at' },
                      'count' => { '$sum' => 1 }
                    }
                  },
                  { '$sort' => { 'created_at' => 1 } }
                ]
              )

              find_graph_data(query.to_a, :count)
            end
        end

        def created_at_in_time_zone
          { 'date' => '$created_at', 'timezone' => Time.zone.tzinfo.name }
        end

        def insights
          @insights ||= InsightViewModel.wrap(
            Workarea::Insights::Base.by_dashboard('marketing').page(options[:page])
          )
        end

        private

        def traffic_referrer_report
          @traffic_referrer_report ||= Workarea::Reports::SalesByTrafficReferrer.new(
            starts_at: starts_at,
            ends_at: ends_at,
            sort_by: 'revenue',
            sort_direction: 'desc'
          )
        end
      end
    end
  end
end
