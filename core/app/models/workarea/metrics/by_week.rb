# frozen_string_literal: true
module Workarea
  module Metrics
    module ByWeek
      extend ActiveSupport::Concern
      include ApplicationDocument
      include Scoring

      included do
        store_in client: :metrics

        field :reporting_on, type: Time, default: -> { Time.current }

        index({ reporting_on: 1 }, { expire_after_seconds: 2.years.seconds.to_i })

        scope :last_week, -> do
          # Use date math to avoid DST-related boundary shifts.
          # We want the previous calendar week, not "now minus 7 days".
          start_of_this_week = Time.current.to_date.beginning_of_week
          start_of_last_week = start_of_this_week - 1.week

          where(
            :reporting_on.gte => start_of_last_week.in_time_zone,
            :reporting_on.lt => start_of_this_week.in_time_zone
          )
        end
      end

      module ClassMethods
        def append!(scope)
          per_page = Workarea.config.insights_aggregation_per_page
          pages = scope.page(1).per(per_page).total_pages

          pages.times do |page|
            models = scope.page(page + 1).per(per_page).to_a
            collection.insert_many(models.map(&:as_document))
          end
        end
      end
    end
  end
end
