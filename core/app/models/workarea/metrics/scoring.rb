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
        difference = Time.current.beginning_of_week - reporting_on.beginning_of_week
        difference / 1.week
      end
    end
  end
end
