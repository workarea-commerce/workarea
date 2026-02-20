module Workarea
  module Metrics
    module Scoring
      extend ActiveSupport::Concern

      included do
        scope :since, ->(time) { where(:reporting_on.gte => time) }
      end

      class_methods do
        def score(field)
          scoped.sum { |i| i.score(field) }
        end
      end

      def score(field)
        if weeks_ago.zero?
          send(field)
        else
          send(field) * (Workarea.config.score_decay / weeks_ago)
        end
      end

      def weeks_ago
        # Use date math instead of second-based math to avoid DST boundary issues.
        # (e.g. a "week" containing a DST shift is not always 7 * 24 hours)
        current_week = Time.current.to_date.beginning_of_week
        reporting_week = reporting_on.to_date.beginning_of_week

        ((current_week - reporting_week) / 7).to_i
      end
    end
  end
end
