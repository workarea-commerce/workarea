require 'test_helper'

module Workarea
  module Storefront
    module Checkout
      class SummaryViewModelTest < TestCase
        def order
          @order ||= Order.new
        end

        def checkout
          @checkout ||= Workarea::Checkout.new(order)
        end

        def test_show_shipping_options?
          summary = SummaryViewModel.new(checkout)
          refute(summary.show_shipping_options?)

          order.add_item(product_id: 'PROD1', sku: 'SKU', quantity: 1)
          summary.shippings.each { |s| s.stubs(show_options?: false) }
          refute(summary.show_shipping_options?)

          summary.shippings.first.stubs(show_options?: true)
          assert(summary.show_shipping_options?)
        end
      end
    end
  end
end
