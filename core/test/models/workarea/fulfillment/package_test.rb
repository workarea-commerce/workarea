require 'test_helper'

module Workarea
  class Fulfillment
    class PackageTest < TestCase
      def test_create
        events = [
          Event.new(
            status: 'shipped',
            quantity: 1,
            data: { 'tracking_number' => '1z1' }
          ),
          Event.new(
            status: 'shipped',
            quantity: 1,
            data: { 'tracking_number' => '1z2' }
          ),
          Event.new(
            status: 'canceled',
            quantity: 1
          ),
          Event.new(
            status: 'shipped',
            quantity: 1,
            data: {}
          ),
          Event.new(
            status: 'shipped',
            quantity: 1,
            data: {}
          ),
        ]

        result = Package.create(events)

        assert_equal(3, result.length)
        assert_equal('1z1', result.first.tracking_number)
        assert_equal('1z2', result.second.tracking_number)
        assert_nil(result.third.tracking_number)
      end
    end
  end
end
