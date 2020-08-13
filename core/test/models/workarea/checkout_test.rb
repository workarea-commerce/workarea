require 'test_helper'

module Workarea
  class CheckoutTest < TestCase
    setup :set_models

    def set_models
      @user = create_user
      @product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])
      @order = create_order(items: [{ product_id: @product.id, sku: 'SKU' }])
    end

    def test_starts_as
      checkout = Checkout.new(@order, @user)
      @user.email = 'bcrouse@workarea.com'

      checkout.start_as(:guest)
      assert_nil(checkout.user)
      assert(checkout.order.user_id.blank?)

      checkout.start_as(@user)
      assert_equal(@user.id.to_s, checkout.order.user_id)
      assert_equal(@user, checkout.user)
    end

    def test_reset
      checkout = Checkout.new(@order)
      checkout.shipping.save!
      checkout.payment.save!
      checkout.reset!

      assert_equal(0, Shipping.count)
      assert_equal(0, Payment.count)

      assert(checkout.shipping.new_record?)
      assert(checkout.payment.new_record?)
    end

    def test_reset_sets_up_new_instances
      checkout = Checkout.new(@order)
      shipping_id = checkout.shipping.object_id
      payment_id = checkout.payment.object_id
      checkout.reset!

      assert_equal(0, Shipping.count)
      assert_equal(0, Payment.count)

      assert(checkout.shipping.new_record?)
      assert(checkout.payment.new_record?)
      refute_equal(shipping_id, checkout.shipping.object_id)
      refute_equal(payment_id, checkout.payment.object_id)
    end

    def test_update
      create_shipping_service
      checkout = Checkout.new(@order)

      checkout.start_as(:guest)

      refute(
        checkout.update(
          email: 'test@workarea.com',
          shipping_address: {
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          },
          billing_address: {
            first_name: 'Ben',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          }
        )
      )

      assert(
        checkout.update(
          email: 'test@workarea.com',
          shipping_address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          },
          billing_address: {
            first_name: 'Ben',
            last_name: 'Crouse',
            street: '22 S. 3rd St.',
            street_2: 'Second Floor',
            city: 'Philadelphia',
            region: 'PA',
            postal_code: '19106',
            country: 'US'
          }
        )
      )
    end

    def test_continue_as
      checkout = Checkout.new(@order)
      checkout.continue_as(@user)

      assert_equal(@user.id.to_s, checkout.order.user_id)
      assert_equal(@user.email, checkout.payment_profile.email)
      assert_equal(checkout.payment.profile_id, checkout.payment_profile.id)

      create_shipping_service

      @user.auto_save_shipping_address(
        first_name: 'Ben',
        last_name: 'Crouse',
        street: '12 N. 3rd St.',
        city: 'Philadelphia',
        region: 'PA',
        postal_code: '19106',
        country: 'US',
        phone_number: '2159251800'
      )

      checkout.start_as(:guest)
      checkout.update(
        email: 'test@workarea.com',
        shipping_address: {
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          street_2: 'Second Floor',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US'
        },
        billing_address: {
          first_name: 'Ben',
          last_name: 'Crouse',
          street: '22 S. 3rd St.',
          street_2: 'Second Floor',
          city: 'Philadelphia',
          region: 'PA',
          postal_code: '19106',
          country: 'US'
        }
      )

      checkout.continue_as(@user)
      assert_equal(@user.id.to_s, @order.user_id)
      assert_equal('22 S. 3rd St.', checkout.shipping.address.street)
    end

    def test_user_changed
      @order.update_attributes!(user_id: @user.id)

      checkout = Checkout.new(@order)
      refute(checkout.user_changed?)

      checkout = Checkout.new(@order, User.new)
      assert(checkout.user_changed?)

      checkout = Checkout.new(Order.new, @user)
      assert(checkout.user_changed?)
    end

    def test_shipping
      checkout = Checkout.new(@order)
      assert(checkout.shipping.instance_of?(Shipping))

      checkout = Checkout.new(Order.new) # doesn't require shipping
      assert_nil(checkout.shipping)
    end

    def test_complete
      checkout = Checkout.new(@order)
      refute(checkout.complete?)

      @order.expects(:purchasable?).returns(true)
      checkout.steps.each do |step|
        step.any_instance.expects(:complete?).returns(true).at_least_once
      end
      assert(checkout.complete?)

      @order.expects(:purchasable?).returns(true)
      checkout.steps.last.any_instance.expects(:complete?).returns(false)
      refute(checkout.complete?)
    end

    def test_place_order_fails_unless_complete
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(false)
      checkout.inventory.expects(:purchase).never
      checkout.payment_collection.expects(:purchase).never

      refute(checkout.place_order)
      refute(@order.reload.placed?)
    end

    def test_place_order_fails_unless_valid_shipping
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(true)
      checkout.expects(:shippable?).returns(false)
      checkout.inventory.expects(:purchase).never
      checkout.payment_collection.expects(:purchase).never

      refute(checkout.place_order)
      refute(@order.reload.placed?)
    end

    def test_place_order_fails_unless_valid_payment
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(true)
      checkout.expects(:shippable?).returns(true)
      checkout.expects(:payable?).returns(false)
      checkout.inventory.expects(:purchase).never
      checkout.payment_collection.expects(:purchase).never

      refute(checkout.place_order)
      refute(@order.reload.placed?)
    end

    def test_place_order_fails_for_fraud
      @order.email = 'decline@workarea.com'
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(true)
      checkout.expects(:shippable?).returns(true)
      checkout.expects(:payable?).returns(true)
      checkout.inventory.expects(:purchase).never
      checkout.payment_collection.expects(:purchase).never

      refute(checkout.place_order)
      refute(@order.reload.placed?)
    end

    def test_place_order_fails_if_inventory_fails
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(true)
      checkout.expects(:shippable?).returns(true)
      checkout.expects(:payable?).returns(true)
      checkout.inventory.expects(:captured?).returns(false)
      checkout.payment_collection.expects(:purchase).never

      refute(checkout.place_order)
      refute(@order.reload.placed?)
    end

    def test_place_order_rollsback_inventory_on_payment_failure
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(true)
      checkout.expects(:shippable?).returns(true)
      checkout.expects(:payable?).returns(true)
      checkout.inventory.expects(:captured?).returns(true)
      checkout.payment_collection.expects(:purchase).returns(false)
      checkout.inventory.expects(:rollback)

      refute(checkout.place_order)
      refute(@order.reload.placed?)
    end

    def test_place_order_marks_order_placed
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(true)
      checkout.expects(:shippable?).returns(true)
      checkout.expects(:payable?).returns(true)
      checkout.inventory.expects(:purchase).returns(true)
      checkout.inventory.expects(:captured?).returns(true)
      checkout.payment_collection.expects(:purchase).returns(true)

      assert(checkout.place_order)
      assert(@order.reload.placed?)
    end

    def test_place_order_creates_fulfillment
      checkout = Checkout.new(@order)

      checkout.expects(:complete?).returns(true)
      checkout.expects(:shippable?).returns(true)
      checkout.expects(:payable?).returns(true)
      checkout.inventory.expects(:purchase).returns(true)
      checkout.inventory.expects(:captured?).returns(true)
      checkout.payment_collection.expects(:purchase).returns(true)

      assert(checkout.place_order)
      assert(Fulfillment.find(@order.id).present?)
    end

    def test_shippable
      checkout = Checkout.new(Order.new)
      assert(checkout.shippable?)

      checkout = Checkout.new(@order)
      Checkout::ShippingOptions.any_instance.expects(:valid?).returns(false)
      refute(checkout.shippable?)

      checkout = Checkout.new(@order)
      Checkout::ShippingOptions.any_instance.expects(:valid?).returns(true)
      assert(checkout.shippable?)
    end

    def test_payable
      checkout = Checkout.new(Order.new)
      assert(checkout.payable?)

      checkout = Checkout.new(@order)
      checkout.payment.expects(:valid?).returns(false)
      refute(checkout.payable?)

      checkout.payment.expects(:valid?).returns(true)
      checkout.payment_collection.expects(:valid?).returns(false)
      refute(checkout.payable?)

      checkout.payment.expects(:valid?).returns(true)
      checkout.payment_collection.expects(:valid?).returns(true)
      assert(checkout.payable?)
    end

    def test_adjust_tender_amounts!
      checkout = Checkout.new(@order, @user)
      assert_nil(checkout.adjust_tender_amounts!)

      checkout.start_as(@user)
      checkout.payment_profile.update(store_credit: 5.to_m)
      checkout.payment.save!

      @order.total_price = 2.to_m
      assert(checkout.adjust_tender_amounts!)
      assert_equal(2.to_m, checkout.payment.store_credit.amount)

      @order.total_price = 3.to_m
      assert(checkout.adjust_tender_amounts!)
      assert_equal(3.to_m, checkout.payment.store_credit.amount)
    end
  end
end
