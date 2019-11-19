require 'test_helper'

module Workarea
  module Admin
    class CustomEventsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_creation
        assert_difference 'Workarea::Reports::CustomEvent.count', 1 do
          post admin.report_custom_events_path,
            params: {
              custom_event: {
                name: 'Foo',
                occurred_at: 1.week.ago
              }
            }
        end
      end

      def test_updating
        event = Workarea::Reports::CustomEvent.create!(
          name: 'Foo',
          occurred_at: 1.week.ago
        )

        patch admin.report_custom_event_path(id: event.id),
          params: {
            custom_event: {
              name: 'Bar'
            }
          }

        assert_equal('Bar', Workarea::Reports::CustomEvent.first.name)
      end

      def test_deletion
        event = Workarea::Reports::CustomEvent.create!(
          name: 'Foo',
          occurred_at: 1.week.ago
        )

        delete admin.report_custom_event_path(id: event.id)

        assert_equal(0, Workarea::Reports::CustomEvent.count)
      end
    end
  end
end
