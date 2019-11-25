module Workarea
  module Pricing
    # This is the base class for representing a discount in the system.
    # Available siscounts must be a customized subclass of
    # {Workarea::Pricing::Discount}.
    #
    # They must implement the #apply method, this is the method
    # called to add the price adjustments necessary to discount
    # the order.
    #
    # @example Create a new discount
    #   class FooDiscount < Discount
    #     add_qualifier :foo_qualifies?
    #
    #     def foo_qualifies?(order)
    #       order.email == 'foo@bar.com'
    #     end
    #
    #     def apply(order)
    #        total_amount = 10.to_m
    #        qty_share = total_amount / order.quantity
    #
    #         order.items.each do |item|
    #           item_total = qty_share * item.quantity
    #           item.adjust_pricing(adjustment_data(item_total, quantity))
    #         end
    #
    #         order
    #        end
    #
    #       order
    #     end
    #   end
    #
    class Discount
      include ApplicationDocument
      include Mongoid::Document::Taggable
      include Releasable
      include Commentable

      class MissingConfigurationError < RuntimeError; end

      # @!attribute price_level
      #   @return [String] used when creating adjustment data, one of: order, shipping, item
      #
      class_attribute :price_level

      # @!attribute name
      #   @return [String]
      #
      field :name, type: String, localize: true

      # @!attribute compatible_discount_ids
      #   @return [Array]
      #
      field :compatible_discount_ids, type: Array, default: []

      # @!attribute excluded_category_ids
      #   @return [Boolean] ids of categories that do not qualify for discount
      #
      field :excluded_category_ids, type: Array, default: []

      # @!attribute excluded_product_ids
      #   @return [Boolean] ids of products that do not qualify for discount
      #
      field :excluded_product_ids, type: Array, default: []

      # @!attribute single_use
      #   @return [Boolean]
      #
      field :single_use, type: Boolean, default: false

      # @!attribute allow_sale_items
      #   @return [Boolean]
      #
      field :allow_sale_items, type: Boolean, default: true

      # @!attribute auto_deactivated
      #   @return [Boolean] whether to allow auto deactivation
      #
      field :auto_deactivate, type: Boolean, default: true

      # @!attribute auto_deactivated_at
      #   @return [Boolean] when the discount was last automatically deactivated
      #
      field :auto_deactivated_at, type: Time

      # @!attribute redemptions
      #   @return [Enumerable] a log entry for each time it was redeemed
      #
      has_many :redemptions,
        class_name: 'Workarea::Pricing::Discount::Redemption'

      index(active: 1)
      index(updated_at: 1) # for DeactivateStaleDiscounts

      validates :name, presence: true

      before_validation :stringify_compatible_discount_ids

      # This macro adds a method to the list of qualification methods for
      # this discount. This method should be a predicate method.
      #
      # @example Add a qualifier
      #   class FooDiscount < Discount
      #     add_qualifier :foo_qualifies?
      #
      #     def foo_qualifies?(order)
      #       order.email == 'foo@bar.com'
      #     end
      #   end
      #
      # @param [Symbol] method_name
      # @return [Symbol]
      #
      def self.add_qualifier(method_name)
        @qualifier_methods ||= []
        @qualifier_methods << method_name
      end

      # Methods that should be chcked when determining whether this
      # discount qualifies. The result is the return values of each method
      # ANDed together. Used in {Workarea::Discount#qualifies?}.
      #
      # @return [Array<Symbol>]
      #
      def self.qualifier_methods
        @qualifier_methods || []
      end

      # Deactivate the current scope of discounts, and mark as automatically
      # deactivated.
      #
      def self.auto_deactivate
        where(auto_deactivate: true, active: true)
          .each_by(50) { |d| d.auto_deactivate! }
      end

      # Compare two discounts, used for ensuring discount application order
      # is predictable. Sorts by class using config value discount_application_order
      # then by the discounts id for discounts of the same class.
      #
      # @param [Workarea::Pricing::Discount] other
      # @return [ Integer ] -1, 0, 1.
      #
      def <=>(other)
        self_order = Workarea.config.discount_application_order.index(self.class.name)
        other_order = Workarea.config.discount_application_order.index(other.class.name)

        if self_order.blank? || other_order.blank?
          missing = self_order.blank? ? self.class : other.class

          raise(
            MissingConfigurationError,
            <<-eos.strip_heredoc

            Problem:
              Missing discount application order config for #{missing}
            Summary:
              To determine discount application order, custom discounts must be
              configured so the system knows how to compare discounts in sorting.
            Resolution:
              Check Workarea.config.discount_application_order and ensure that
              all discount class names are added to that list in the desired
              position so they can be properly ordered for application.
            eos
          )
        end

        class_order = self_order <=> other_order

        case class_order
        when -1 then -1
        when 0 then self.id <=> other.id
        when 1 then 1
        end
      end

      # Automatically deactivates a discount
      #
      def auto_deactivate!
        update_attributes!(active: false, auto_deactivated_at: Time.current)
      end

      # Whether this discount qualifies for this order. It does so
      # by checking each qualifier_methods set on the class. If all
      # qualifier_methods return true, the discount qualifies.
      #
      # Returns false if there are no qualified methods setup.
      #
      # @return [Boolean]
      #
      def qualifies?(order)
        return false unless self.class.qualifier_methods.present?
        return false unless order.items.present?
        return false unless can_be_used_by?(order.email)

        self.class.qualifier_methods.reduce(true) do |result, method|
          result && send(method, order)
        end
      end

      # Whether this discount has been redeemed by a certain email
      # address. Used for single use qualification.
      #
      # @param [String] email
      # @return [Boolean]
      #
      def has_been_redeemed?(email)
        redemptions.where(email: email.downcase).exists?
      end

      # Whether this email has already redeemed this discount,
      # and is not eligible due to single use.
      #
      # @param [String] email
      # @return [Boolean]
      #
      def can_be_used_by?(email)
        return true if !single_use? || email.blank?
        !redemptions.where(email: email.downcase).exists?
      end

      # Whether this discount was autodeactivated. Used to show the UI in the
      # admin around what you can do if a discount has been autodeactivated.
      #
      # @return [Boolean]
      #
      def auto_deactivated?
        !active? && auto_deactivate && auto_deactivated_at.present?
      end

      # Find the last redemption for the discount.
      #
      # @return [Workarea::Pricing::Discount::Redemption, nil]
      #
      def last_redemption
        redemptions.desc(:created_at).first
      end

      # Returns the date of auto deactivation if no redemptions occur
      #
      # @return [Time]
      #
      def auto_deactivates_at
        start = last_redemption.try(:created_at) || updated_at
        start + Workarea.config.discount_staleness_ttl
      end

      # Whether this discount is compatible with the one passed
      #
      # @param [Workarea::Pricing::Discount]
      # @return [Boolean]
      #
      def compatible_with?(discount)
        compatible_discount_ids.map(&:to_s).include?(discount.id.to_s) ||
          discount.compatible_discount_ids.map(&:to_s).include?(id.to_s)
      end

      # Record the redemption of this discount by an email address
      # for an amount. Used for reporting and use tracking.
      #
      # @param [String] email
      #
      # @return [Workarea::Pricing::Discount::Redemption]
      #
      def log_redemption(email)
        redemptions.create!(email: email)
      end

      # Create the price adjustments that reduce the order price.
      # This method must be implemented when subclassing
      # (creating a new type of) discount. It's effects will vary
      # discount to discount.
      #
      # @param [Workarea::Order] order
      # @return [Workarea::Order]
      #
      def apply(order)
        raise(
          NotImplementedError,
          "#{self.class} must implement the #apply method"
        )
      end

      # Removes the adjustments created by this discount.
      # Used after this discount has been disqualified at
      # the end of discount application.
      #
      # @param [Workarea::Order] order
      # @return [Workarea::Order]
      #
      def remove_from(order)
        remove_from_items(order.items + order.shippings)
      end

      # Whether or not the provided product_id is excluded from the discount
      #
      # @param [String] product_id
      # @return [Boolean]
      #
      def excludes_product_id?(product_id)
        excluded_product_ids.include?(product_id.to_s)
      end

      # Whether or not the provided category_id is excluded from the discount
      #
      # @param [String] category_id
      # @return [Boolean]
      #
      def excludes_category_id?(category_id)
        excluded_category_ids.include?(category_id.to_s)
      end

      # @private
      #
      # The set of compatible discounts for creating an undirected graph
      # of discount compatibility for finding ApplicationGroups most
      # efficiently.
      #
      # @return [Set<Workarea::Pricing::Discount>]
      #
      def compatible_discounts
        @compatible_discounts ||= Set.new
      end

      private

      # Build the data {Hash} used to create the price
      # adjustment.
      #
      # @param [Money] value
      # @param [Integer] quantity
      # @return [Hash]
      #
      def adjustment_data(value, quantity)
        value = value.abs

        {
          price: self.class.price_level,
          description: name,
          calculator: self.class.name,
          amount: 0.to_m - value,
          quantity: quantity,
          data: {
            'discount_id' => id.to_s,
            'discount_value' => value.to_f
          }
        }
      end

      def remove_from_items(items)
        items.each do |item|
          keepers = item.price_adjustments.reject do |adjustment|
            adjustment.data['discount_id'] == id.to_s
          end

          item.price_adjustments = keepers
        end
      end

      private

      def stringify_compatible_discount_ids
        if compatible_discount_ids.present?
          compatible_discount_ids.map!(&:to_s)
        end
      end
    end
  end
end
