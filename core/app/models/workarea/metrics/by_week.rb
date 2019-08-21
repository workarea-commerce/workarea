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
          where(
            :reporting_on.gte => Time.current.last_week,
            :reporting_on.lt => Time.current.last_week.end_of_week
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
