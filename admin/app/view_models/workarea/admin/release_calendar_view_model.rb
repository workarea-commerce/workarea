module Workarea
  module Admin
    class ReleaseCalendarViewModel < ApplicationViewModel

      def days
        @days ||= date_range.reduce({}) do |days, date|
          days.merge(date.strftime("%Y-%m-%d") => find_releases_for_date(date))
        end
      end

      def prev_week
        start_date - 1.week
      end

      def next_week
        start_date + 1.week
      end

      def weekdays
        date_range.slice(0, 7).map { |d| Date::ABBR_DAYNAMES[d.wday] }
      end

      def start_date
        options.fetch(:start_date, Time.zone.today).to_date
      end

      def unscheduled
        @unscheduled ||= Release.unscheduled.to_a
      end

      private

      def find_releases_for_date(date)
        releases_in_range.map{ |r| ReleaseViewModel.new(r, options) }
                         .select { |r| date_within_range?(date, r) }
      end

      def date_within_range?(date, release)
        return true if date == release.publish_time.to_date
        return false if release.undo_at.blank?

        date.to_time.to_i.between?(release.publish_time.to_i, release.undo_at.to_i)
      end

      def releases_in_range
        @releases ||= Release.published_within(date_range.first, date_range.last)
      end

      def date_range
        range_start = start_date.beginning_of_week(start_day = :sunday) - 1.week
        range_end = start_date.end_of_week(start_day = :sunday) + 2.weeks

        (range_start..range_end).to_a
      end
    end
  end
end
