require 'active_support/testing/time_helpers'

module Workarea
  class OrdersSeeds
    include ActiveSupport::Testing::TimeHelpers

    def perform
      puts 'Adding orders...'

      12.times do |i|
        travel_to((i + 1).weeks.ago)
        create_order
        travel_back
      end

      8.times do
        travel_to rand(80).days.ago
        create_order
        travel_back
      end

      create_order
    end

    def create_order
      user = User.sample

      if user.first_name.blank? || user.last_name.blank?
        user.update_attributes!(
          first_name: Faker::Name.first_name,
          last_name: Faker::Name.last_name
        )
      end

      unless user.addresses.count > 0
        user.addresses.create!(
          first_name: user.first_name,
          last_name: user.last_name,
          street: Faker::Address.street_address,
          city: Faker::Address.city,
          postal_code: Faker::Address.zip_code,
          region: Faker::Address.state_abbr,
          country: 'US',
          phone_number: Faker::PhoneNumber.cell_phone,
          phone_extension: Faker::PhoneNumber.extension
        )
      end

      payment_profile = Payment::Profile.lookup(PaymentReference.new(user))

      payment_profile.update(store_credit: [0, 10].sample.to_m)

      saved_card = payment_profile.credit_cards.first

      saved_card ||= payment_profile.credit_cards.create!(
        first_name: user.first_name,
        last_name: user.last_name,
        number: '1',
        month: 1,
        year: Time.current.year + 5,
        cvv: '999'
      )

      quantity = rand(2) == 0 ? 1 : 2
      order = Order.find_current(user_id: user.id)

      promo_code = try_promo_code
      order.add_promo_code(promo_code) if promo_code.present?

      2.times do
        sku = find_purchasable_sku
        order.add_item(
          OrderItemDetails.find(sku).to_h.merge(
            sku: sku,
            quantity: rand(2 * quantity) + 1,
            via: find_via
          )
        )
      end

      checkout = Checkout.new(order)
      checkout.start_as(user)
      checkout.update(payment: saved_card.id)
      checkout.place_order

      Payment::Capture
        .new(payment: checkout.payment)
        .tap { |c| c.allocate_amounts!(total: order.reload.total_price) }
        .complete!

      Fulfillment.find(order.id).ship_items(
        '1Z' + rand(99_999_999).to_s,
        order.items.map { |i| { id: i.id, quantity: i.quantity } }
      )
    end

    def find_via
      if rand(2) == 0
        Catalog::Category.sample.to_gid_param
      else
        query = Catalog::Product.sample.name.split(' ').sample
        Navigation::SearchResults.new(q: query).to_gid_param
      end
    end

    def find_purchasable_sku
      Inventory::Sku.where(:available.gt => 8).sample.id
    end

    def try_promo_code
      if [true, false].sample
        Pricing::Discount.pluck(:promo_codes).flatten.sample
      end
    end
  end
end
