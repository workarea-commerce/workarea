module Workarea
  module Insights
    class BestCustomers < Base
      class << self
        def dashboards
          %w(people)
        end

        def generate_monthly!
          [30.days, 180.days, 365.days].each do |days|
            results = find_results(ordered_since: days.ago)

            if results.present?
              create!(results: results.map(&:as_document))
              return
            end
          end
        end

        def find_results(ordered_since:)
          Metrics::User
            .ordered_since(ordered_since)
            .best
            .limit(Workarea.config.insights_users_list_max_results)
            .to_a
        end
      end
    end
  end
end
