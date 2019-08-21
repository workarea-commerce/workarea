require 'test_helper'

module Workarea
  class Shipping
    class RateTest < TestCase
      def test_tiered?
        rate = Workarea::Shipping::Rate.new
        refute(rate.tiered?)

        rate.tier_min = 4
        assert(rate.tiered?)

        rate.tier_min = nil
        rate.tier_max = 4
        assert(rate.tiered?)
      end
    end
  end
end
