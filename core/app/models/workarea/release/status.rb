module Workarea
  class Release
    module Status
      class Unscheduled
        include StatusCalculator::Status

        def in_status?
          model.publish_at.blank? &&
          model.published_at.blank? &&
          model.undo_at.blank?
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
          model.published_at.present? &&
          model.publish_at.blank?
        end
      end

      class Undone
        include StatusCalculator::Status

        def in_status?
          model.published_at.present? &&
          model.undone_at.present?
        end
      end

      class ScheduledUndo
        include StatusCalculator::Status

        def in_status?
          return false unless model.undo_at.present?
          model.published_at.present? &&
          model.undo_at >= Time.current
        end
      end
    end
  end
end
