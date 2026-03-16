require 'test_helper'

module Workarea
  class MoneyCacheSerializationTest < Workarea::IntegrationTest
    def test_money_round_trips_through_rails_cache
      Rails.cache.clear

      original = Money.new(12_34, 'USD')
      Rails.cache.write('money:round_trip', original)
      round_trip = Rails.cache.read('money:round_trip')

      assert_instance_of(Money, round_trip)
      assert_equal(original.cents, round_trip.cents)
      assert_equal(original.currency, round_trip.currency)
    end
  end
end
