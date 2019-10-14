module Workarea
  module Pricing
    class Request
      def initialize(order, shippings)
        @persisted_order = order
        @persisted_shippings = Array(shippings)
        @persisted_payment = Workarea::Payment.find(order.id) rescue nil
      end

      # Builds a duplicate, non-persisted version of the {Workarea::Order}
      # for manipulation during pricing. This allows persisting all pricing changes
      # to the order at once.
      #
      # @return [Workarea::Order]
      #
      def order
        @order ||=
          begin
            result = @persisted_order.clone
            result.id = @persisted_order.id # Ensure this isn't persisted

            # This exists to fix a problem with doing price_adjustments = [] on
            # an unpersisted Order::Item on MongoDB >= 2.6 (which works on 2.4).
            # On 2.4 it doesn't try to make the write so all is fine. I have no
            # idea why this is required only on that version, but it does fix
            # the problem.
            #
            result.attributes = clone_order_attributes
            result
          end
      end

      # Builds a list of duplicate, non-persisted versions of the {Shipping}
      # for manipulation during pricing. This allows persisting all pricing changes
      # to the shipping all at once.
      #
      # @return [Array<Shipping>]
      #
      def shippings
        @shippings ||= @persisted_shippings.map do |shipping|
          result = shipping.clone
          result.id = shipping.id # Ensure this isn't persisted
          result.reset_adjusted_shipping_pricing
          result
        end
      end

      def payment
        return unless @persisted_payment.present?

        @payment ||=
          Workarea::Payment.instantiate(@persisted_payment.as_document).tap do |payment|
            payment.new_record = true # Ensure this isn't persisted by raising duplicate key if saved
          end
      end

      # An enumerable of discounts, which allows single a single db query for discounts
      # to fix N+1 discount queries.
      #
      # @return [Discount::Collection]
      #
      def discounts
        @discounts ||= Discount::Collection.new
      end

      # An enumerable of {Pricing::Sku}, which allows single a single db query for SKUs
      # to fix N+1 SKU queries while running a {Pricing::Request}.
      #
      # @return [Discount::Collection]
      #
      def pricing
        @pricing ||= Pricing::Collection.new(all_skus)
      end

      # Calls each calculator which in turn are what modifies the price
      # adjustments on the order. Does not persist it's changes. This method is
      # how a {Workarea::Order} and corresponding {Shipping} are
      # priced.
      #
      def run
        return unless stale?

        # TODO fix this hack
        order.items.where(free_gift: true).delete_all

        Workarea.config.pricing_calculators.each do |class_name|
          class_name.constantize.new(self).adjust
        end

        shippings.each { |s| ShippingTotals.new(s).total }
        OrderTotals.new(order, shippings).total
      end

      # Persist the changes made to the temporary {Workarea::Order}
      # and its corresponding {Shipping} in as few DB writes as
      # possible.
      #
      def save!
        !stale? || save_order && save_shippings
      end

      def stale?
        @persisted_order.pricing_cache_key != cache_key.to_s
      end

      private

      def cache_key
        @cache_key ||= CacheKey.new(
          @persisted_order,
          @persisted_shippings,
          @persisted_payment,
          self
        )
      end

      def clone_order_attributes
        attributes = @persisted_order.as_document.except('_id','id')

        if attributes['items'].present?
          attributes['items'].each { |i| i['price_adjustments'] = [] }
        end

        attributes
      end

      def all_skus
        skus = [
          order.items.map(&:sku),
          order.items.map { |i| i.customizations['pricing_sku'] },
          discounts.skus
        ]

        skus.flatten.reject(&:blank?).uniq
      end

      def save_order
        # as_document won't contain items in the hash if there isn't any items left.
        # ensure the items get cleared out when this happens
        @persisted_order.update_attributes!(order.as_document.reverse_merge(items: []))
        cache_key.order = @persisted_order
        @persisted_order.set(pricing_cache_key: cache_key.to_s)
      end

      def save_shippings
        shippings.each do |tmp_shipping|
          shipping_attrs = tmp_shipping.as_document
          matching_shipping = @persisted_shippings.detect do |s|
             s.id == tmp_shipping.id
          end

          matching_shipping.update_attributes!(shipping_attrs)
        end
      end
    end
  end
end
