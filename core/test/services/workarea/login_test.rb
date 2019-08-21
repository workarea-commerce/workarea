require 'test_helper'

module Workarea
  class LoginTest < TestCase
    def user
      @user ||= create_user
    end

    def order
      @order ||= Order.create!
    end

    def test_perform
      Login.new(user, order).perform

      order.reload
      assert_equal(user.id.to_s, order.user_id)
      assert(user.last_login_at.present?)
    end

    def test_perform_merging_carts
      product_1 = create_product(variants: [{ sku: 'sku1' }])
      product_2 = create_product(variants: [{ sku: 'sku2' }])

      previous_order = Order.create!(user_id: user.id)
      previous_order.items.create!(product_id: product_1.id, sku: product_1.skus.first)

      order.items.create!(product_id: product_2.id, sku: product_2.skus.first)

      login = Login.new(user, order).tap(&:perform)

      assert_equal(previous_order, login.current_order)
      assert_equal(2, login.current_order.items.length)
      assert_equal(product_1.id, login.current_order.items.first.product_id)
      assert_equal(product_1.skus.first, login.current_order.items.first.sku)
      assert_equal(product_2.id, login.current_order.items.second.product_id)
      assert_equal(product_2.skus.first, login.current_order.items.second.sku)
    end

    def test_perform_using_most_recently_updated_cart
      old_order = Order.create!(user_id: user.id, items: [{ product_id: 'P', sku: 'S' }])
      old_order.updated_at = 1.day.ago
      old_order.save!

      recent_order = Order.create!(user_id: user.id, items: [{ product_id: 'P', sku: 'S' }])

      login = Login.new(user, order)
      login.perform

      assert_equal(recent_order, login.current_order)
    end

    def test_perform_does_not_merge_cart_began_checkout
      previous_order = Order.create!(
        user_id: user.id,
        checkout_started_at: Time.current,
        items: [{ product_id: 'P', sku: 'S' }]
      )

      order.items.create!(product_id: 'P2', sku: 'S2')

      login = Login.new(user, order).tap(&:perform)

      assert_equal(order, login.current_order)
      assert_equal(1, login.current_order.items.length)
      assert_equal('P2', login.current_order.items.first.product_id)
      assert_equal('S2', login.current_order.items.first.sku)

      assert_equal(1, previous_order.items.length)
      assert_equal('P', previous_order.items.first.product_id)
      assert_equal('S', previous_order.items.first.sku)
    end
  end
end
