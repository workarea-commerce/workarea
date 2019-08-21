require 'test_helper'

module Workarea
  module Storefront
    module Checkout
      class AddressesViewModelTest < TestCase
        def test_shipping_address_returns_an_empty_shipping_address_when_shipping_is_nil
          checkout = Workarea::Checkout.new(Order.new)
          step = Workarea::Checkout::Steps::Addresses.new(checkout)
          view_model = Storefront::Checkout::AddressesViewModel.new(step)
          assert_instance_of(Shipping::Address, view_model.shipping_address)
        end
      end
    end
  end
end
