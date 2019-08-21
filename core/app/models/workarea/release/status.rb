module Workarea
  class Release
    module Status
      class Unscheduled
        include StatusCalculator::Status

        def in_status?
          model.publish_at.blank? && model.published_at.blank?
        end
      end

      class Scheduled
        include StatusCalculator::Status

        def in_status?
          return false unless model.publish_at.present?
          model.publish_at >= Time.current
        end
      end

      class Published
        include StatusCalculator::Status

        def in_status?
          model.published_at.present? && model.publish_at.blank?
        end
      end
    end
  end
end
