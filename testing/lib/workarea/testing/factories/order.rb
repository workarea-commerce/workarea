module Workarea
  module Factories
    module Order
      class UnplacedOrderError < RuntimeError; end

      Factories.add(self)

      def create_order(overrides = {})
        attributes = factory_defaults(:order).merge(overrides)
        Workarea::Order.new(attributes).tap(&:save!)
      end

      def create_placed_order(overrides = {})
        attributes = factory_defaults(:placed_order).merge(overrides)

        shipping_service = create_shipping_service
        sku = 'SKU'
        create_product(variants: [{ sku: sku, regular: 5.to_m }])
        details = OrderItemDetails.find(sku)
        order = Workarea::Order.new(attributes)
        item = { sku: sku, quantity: 2 }.merge(details.to_h)

        order.add_item(item)

        checkout = Checkout.new(order)
        checkout.update(
          factory_defaults(:checkout_payment).merge(
            shipping_address: factory_defaults(:shipping_address),
            billing_address: factory_defaults(:billing_address),
            shipping_service: shipping_service.name,
          )
        )

        # In some environments, the first pass of setting a shipping service can
        # persist without the base shipping price adjustment, which then causes
        # `Checkout#shippable?`/`Checkout#place_order` to fail. Re-applying the
        # currently selected option ensures `Shipping#base_price` is set.
        if order.requires_shipping?
          shipping = checkout.shippings.first

          if shipping&.shipping_service.present?
            option = Workarea::Checkout::ShippingOptions
              .new(order, shipping)
              .find_valid(shipping.shipping_service.name)

            shipping.set_shipping_service(option.to_h) if option.present?
          end
        end

        unless checkout.place_order
          shipping_errors = checkout
            .shippings
            .map { |s| s.errors.full_messages }
            .flatten
            .presence

          message = [
            'failed placing the order in the create_placed_order factory',
            "complete?=#{checkout.complete?}",
            "shippable?=#{checkout.shippable?}",
            "payable?=#{checkout.payable?}",
            ("shipping_errors=#{shipping_errors.inspect}" if shipping_errors.present?),
            ("payment_errors=#{checkout.payment.errors.full_messages.inspect}" if checkout.payment&.errors&.any?)
          ].compact.join(' ')

          raise(UnplacedOrderError, message)
        end

        forced_attrs = overrides.slice(:placed_at, :updated_at, :total_price)
        order.update_attributes!(forced_attrs)
        order
      end

      def complete_checkout(order, options = {})
        shipping_address =
          factory_defaults(:shipping_address).merge(options[:shipping_address] || {})

        billing_address =
          factory_defaults(:billing_address).merge(options[:billing_address] || {})

        payment = factory_defaults(:checkout_payment).tap do |payment|
          payment[:credit_card].merge(options[:credit_card] || {})
        end

        shipping_service = options[:shipping_service].presence ||
                            create_shipping_service.name

        order.items.each do |item|
          item.update_attributes!(OrderItemDetails.find!(item.sku).to_h)
        end

        checkout = Checkout.new(order)
        checkout.update(
          payment.merge(
            shipping_address: shipping_address,
            billing_address: billing_address,
            shipping_service: shipping_service,
          )
        )

        checkout.place_order
      end

      def create_fraudulent_order(overrides = {})
        attributes = factory_defaults(:fraudulent_order).merge(overrides)
        decision_attributes = attributes.slice(:fraud_decision)

        decision = create_fraud_decision(decision_attributes[:fraud_decision])

        shipping_service = create_shipping_service
        sku = 'SKU'
        create_product(variants: [{ sku: sku, regular: 5.to_m }])
        details = OrderItemDetails.find(sku)
        order = Workarea::Order.new(attributes)

        item = { sku: sku, quantity: 2 }.merge(details.to_h)

        order.add_item(item)

        checkout = Checkout.new(order)
        checkout.update(
          factory_defaults(:checkout_payment).merge(
            shipping_address: factory_defaults(:shipping_address),
            billing_address: factory_defaults(:billing_address),
            shipping_service: shipping_service.name,
          )
        )

        order.set_fraud_decision!(decision)
        order
      end

      def create_fraud_decision(overrides = {})
        attributes = factory_defaults(:fraud_decision).merge(overrides)
        Workarea::Order::FraudDecision.new(attributes)
      end
    end
  end
end
