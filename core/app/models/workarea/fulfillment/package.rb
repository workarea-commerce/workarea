module Workarea
  class Fulfillment
    class Package
      def self.create(events)
        tracking_numbers = events
                            .select { |e| e.status == 'shipped' }
                            .map { |e| e.data['tracking_number'] }
                            .uniq

        tracking_numbers.map do |tracking_number|
          matching_events = events.select do |event|
            event.status == 'shipped' &&
              event.data['tracking_number'] == tracking_number
          end

          Package.new(tracking_number, matching_events)
        end
      end

      attr_reader :tracking_number, :events

      def initialize(tracking_number, events = [])
        @tracking_number = tracking_number
        @events = events
      end

      def events_by_item
        @events.group_by(&:order_item_id)
      end

      def created_at
        sorted_event_creation_dates.first
      end

      def updated_at
        sorted_event_creation_dates.last
      end

      private

      def sorted_event_creation_dates
        @sorted_event_creation_dates ||= events.map(&:created_at)
      end
    end
  end
end
