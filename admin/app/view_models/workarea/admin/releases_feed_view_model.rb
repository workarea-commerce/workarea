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
              event.dtstart = format_date(release.starts_at)
              event.dtend = format_date(release.ends_at)
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
          Release.published_within(Time.current, 1.year.from_now)
        )
      end

      def format_date(time)
        return unless time.present?
        Icalendar::Values::DateTime.new(time, tzid: timezone_id)
      end
    end
  end
end
