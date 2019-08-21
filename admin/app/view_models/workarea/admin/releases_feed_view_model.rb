module Workarea
  module Admin
    class ReleasesFeedViewModel < ApplicationViewModel
      delegate :to_ical, to: :calendar

      def calendar
        @calendar ||= Icalendar::Calendar.new.tap do |calendar|
          calendar.add_timezone(calendar_timezone)

          calendar.x_wr_calname = I18n.t(
            'workarea.admin.releases.feed.name',
            site_name: Workarea.config.site_name
          )

          releases.each do |release|
            calendar.event do |event|
              event.dtstart = format_date(release.starts_at, release.all_day_event?)
              event.dtend = format_date(release.ends_at, release.all_day_event?)
              event.summary = release.name
              event.description = release.description
            end
          end

          calendar
        end
      end

      private

      def timezone_id
        Time.zone.tzinfo.identifier
      end

      def calendar_timezone
        TZInfo::Timezone.get(timezone_id).ical_timezone(Time.current)
      end

      def releases
        @releases ||= Admin::ReleaseEventViewModel.wrap(
          (
            Release.published_within(Time.current, 1.year.from_now) +
            Release.undone_within(Time.current, 1.year.from_now)
          ).uniq
        )
      end

      def format_date(time, date_only = false)
        return unless time.present?

        if date_only
          Icalendar::Values::Date.new(time.to_date, tzid: timezone_id)
        else
          Icalendar::Values::DateTime.new(time, tzid: timezone_id)
        end
      end
    end
  end
end
