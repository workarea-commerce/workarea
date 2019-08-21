require 'test_helper'

module Workarea
  class ShippingCarrierViewModelTest < TestCase
    class FooViewModel < ApplicationViewModel
      include ShippingCarrierViewModel
    end

    def ups_number
      '1ZW004A1PP07646821'
    end

    def fedex_number
      '398894880779734'
    end

    def usps_number
      '9102931502928051489189'
    end

    def test_handles_blank
      view_model = FooViewModel.wrap(nil)
      assert(view_model.carrier.blank?)
      assert(view_model.tracking_link.blank?)
    end

    def test_carrier
      package = Fulfillment::Package.new(ups_number)
      assert_equal('UPS', FooViewModel.wrap(package).carrier)

      package = Fulfillment::Package.new(fedex_number)
      assert_equal('FedEx', FooViewModel.wrap(package).carrier)

      package = Fulfillment::Package.new(usps_number)
      assert_equal('USPS', FooViewModel.wrap(package).carrier)
    end

    def test_tracking_link
      package = Fulfillment::Package.new(ups_number)
      assert_includes(FooViewModel.wrap(package).tracking_link, 'ups')

      package = Fulfillment::Package.new(fedex_number)
      assert_includes(FooViewModel.wrap(package).tracking_link, 'fedex')

      package = Fulfillment::Package.new(usps_number)
      assert_includes(FooViewModel.wrap(package).tracking_link, 'usps')
    end
  end
end
