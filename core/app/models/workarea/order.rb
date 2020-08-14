module Workarea
  class Order
    include ApplicationDocument
    include Queries
    include UrlToken
    include DiscountIds
    include NormalizeEmail
    include Commentable
    include Lockable

    field :_id, type: String, default: -> { SecureRandom.hex(5).upcase }
    field :email, type: String
    field :placed_at, type: Time
    field :promo_codes, type: Array, default: []
    field :user_id, type: String
    field :canceled_at, type: Time
    field :ip_address, type: String
    field :checkout_started_at, type: Time
    field :reminded_at, type: Time
    field :subtotal_price, type: Money, default: 0
    field :discount_total, type: Money, default: 0
    field :shipping_total, type: Money, default: 0
    field :tax_total, type: Money, default: 0
    field :total_value, type: Money, default: 0
    field :total_price, type: Money, default: 0
    field :checkout_by_id, type: String
    field :pricing_cache_key, type: String
    field :source, type: String
    field :metrics_saved_at, type: Time
    field :user_agent, type: String
    field :segment_ids, type: Array, default: []
    field :fraud_suspected_at, type: Time
    field :fraud_decided_at, type: Time

    # @deprecated as of v3.2, locks are handled via Workarea::Lock
    field :lock_expires_at, type: Time

    # @deprecated as of v3.5, the email address will be the ID for {Metrics}
    field :user_activity_id, type: String

    index({ user_id: 1 })
    index({ placed_at: 1, created_at: 1 })
    index({ created_at: 1 })
    index({ updated_at: 1 })
    index({ checkout_started_at: 1 })
    index({ email: 1, placed_at: 1 })
    index(
      {
        placed_at: 1,
        reminded_at: 1,
        fraud_suspected_at: 1,
        checkout_started_at: 1,
        email: 1,
        "items[0]._id": 1
      },
      {
        name: 'abandoned_order_email_with_fraud_index_v2',
        background: true
      }
    )

    belongs_to :copied_from,
      class_name: 'Workarea::Order',
      optional: true,
      index: true

    embeds_many :items,
      class_name: 'Workarea::Order::Item',
      inverse_of: :order,
      cascade_callbacks: true,
      extend: ItemsExtension

    embeds_one :traffic_referrer,
      class_name: 'Workarea::TrafficReferrer'

    embeds_one :fraud_decision,
      class_name: 'Workarea::Order::FraudDecision'

    validates :email, presence: { on: :purchasable }, email: true

    validate :item_count_limit

    define_model_callbacks :place

    # The user-friendly name for the order
    #
    # @return [String]
    #
    def name
      I18n.t('workarea.order.name', id: id)
    end

    # The number of units in this order.
    #
    # @return [Integer]
    #
    def quantity
      items.select(&:valid?).sum(&:quantity)
    end

    # All price adjustments on this order.
    #
    # @return [PriceAdjustmentSet]
    #
    def price_adjustments
      PriceAdjustmentSet.new(items.map(&:price_adjustments).flatten)
    end

    # Whether this order is empty.
    #
    # @return [Boolean]
    #
    def no_items?
      quantity == 0
    end

    # Update the checkout timestamp to indicate the last time
    # this checkout was active and optionally set checkout user data
    #
    # @return [Boolean]
    #
    def touch_checkout!(attributes = {})
      update_attribute(:checkout_started_at, Time.current)
      assign_attributes(
        attributes.slice(
          :ip_address,
          :user_activity_id,
          :checkout_by_id,
          :source,
          :traffic_referrer,
          :user_agent,
          :segment_ids
        )
      )
    end

    # Mark this order as having been reminded. Used in the
    # reminding worker to ensure an Order doesn't get
    # reminded twice.
    #
    # @return [Boolean]
    #
    def mark_as_reminded!
      self.reminded_at = Time.current
      save!(validate: false)
    end

    # Whether this order has ever started checkout
    #
    # @return [Boolean]
    #
    def started_checkout?
      checkout_started_at.present?
    end

    # Whether this order is currently checking out, defined
    # as whether they've touched checkout within Workarea.config.checkout_expiration
    #
    # @return [Boolean]
    #
    def checking_out?
      return false unless checkout_started_at.present?

      checkout_expires_at = checkout_started_at +
                              Workarea.config.checkout_expiration

      checkout_expires_at > Time.current
    end

    # Clears out order checkout details, effectively placing
    # the order back into a cart state.
    #
    # Explicitly does not reset email or shipping service
    # since these can be carried in and out of checkout.
    #
    # Email can be set by being logged in or not, shipping
    # method can be set by estimation on the cart page.
    #
    # @return [Boolean]
    #
    def reset_checkout!
      self.user_id = nil
      self.checkout_started_at = nil
      self.token = nil
      save!
    end

    # Check to see if this order delivers with any of the fulfillment policies
    # passed in.
    #
    # @param [String,Symbol]
    # @return [Boolean]
    #
    def fulfilled_by?(*types)
      items.any? { |i| i.fulfilled_by?(*types) }
    end

    # Whether any of the order's items require physical shipping.
    #
    # @return [Boolean]
    #
    def requires_shipping?
      fulfilled_by?(:shipping)
    end

    # Whether this order can be purchased, which is defined here as the order
    # having items and an email address.
    #
    # @return [Boolean]
    #
    def purchasable?
      items.present? && valid?(:purchasable)
    end

    # Whether this order was placed.
    #
    # @return [Boolean]
    #
    def placed?
      !!placed_at
    end

    # Place the order.
    #
    # @return [Boolean]
    #   whether the order was placed
    #
    def place
      return false unless purchasable?

      run_callbacks :place do
        self.placed_at = Time.current
        with(write: { w: "majority", j: true }) { save }
      end
    end

    # Adds an item to the order. Increases quantity if the SKU is already in the order.
    #
    # @param [Hash] attributes
    # @return [Boolean] success
    #
    def add_item(attributes)
      quantity = attributes.fetch(:quantity, 1).to_i
      sku = attributes[:sku]

      if existing_item = items.find_existing(sku, attributes)
        update_item(existing_item.id, quantity: existing_item.quantity + quantity)
      else
        items.build(attributes)
      end

      save
    end

    # Update an item's attributes. When quantity is provided for an
    # existing item, increase quantity by the provided value rather than
    # set the quantity to the passed-in value.
    #
    # @param [String] id
    # @param [Hash] attributes - new item attributes
    #
    # @return [Boolean]
    #   whether the item was successfully updated
    def update_item(id, attributes)
      existing_item = items.find_existing(attributes[:sku], attributes)

      if existing_item.present? && existing_item.id.to_s != id.to_s
        item = items.find(id)
        existing_item.update_attributes(quantity: existing_item.quantity + (attributes[:quantity] || item.quantity))
        item.delete
      else
        items.find(id).update_attributes(attributes)
      end
    end

    # Removes an item from the order
    #
    # @param [String] id item id
    # @return [self]
    #
    def remove_item(id)
      items.find(id).destroy
      self
    end

    # Adds a promo code to the order. Ensures only unique
    # promo codes remain in the order promo code list.
    #
    # @param [String] promo code
    # @return [self]
    #
    def add_promo_code(code)
      promo_codes << code
      promo_codes.map!(&:upcase)
      promo_codes.uniq!
      save
      self
    end

    # Whether an item of this SKU is in this order
    #
    # @param [String] sku
    # @return [Boolean]
    #
    def has_sku?(sku)
      items.any? { |i| i.sku == sku }
    end

    # Whether this order is considered abandoned.
    # This means not canceled or placed and not checking
    # out within the active period.
    #
    # @return [Boolean]
    #
    def abandoned?
      !canceled? && !placed? && !checking_out? &&
        created_at + Workarea.config.order_active_period < Time.current
    end

    # Get the status of this order. Does NOT include fulfillment statuses like
    # shipped, partially shipped, etc.
    #
    # @return [Symbol]
    #
    def status
      calculators = Workarea.config.order_status_calculators.map(&:constantize)
      StatusCalculator.new(calculators, self).result
    end

    # Whether this order has been canceled.
    #
    # @return [Boolean]
    #
    def canceled?
      !!canceled_at
    end

    # Whether this order was copied from another
    def copied?
      copied_from.present?
    end

    # Cancel this order.
    #
    def cancel
      update_attribute(:canceled_at, Time.current)
    end

    # Check whether metrics were saved for this order. Used to ensure this
    # doesn't happen more than once due to Sidekiq's semantics (run at least
    # once).
    def metrics_saved?
      !!metrics_saved_at
    end

    # Mark the metrics for the order saved.
    def metrics_saved!
      set(metrics_saved_at: Time.current)
    end

    # Whether this order is suspected of fraud.
    #
    # @return [Boolean]
    #
    def fraud_suspected?
      !!fraud_suspected_at
    end

    # Sets the fraud descision for the order..
    #
    # @param [Workarea::Order::FraudDecision] decision
    # @return [Boolean]
    #
    def set_fraud_decision!(decision)
      update!(
        fraud_decision: decision,
        fraud_decided_at: Time.current,
        fraud_suspected_at: decision.declined? ? Time.current : nil
      )
    end

    # A hash with the quantity of each SKU in the order
    #
    # @return [Hash]
    #
    def sku_quantities
      items.each_with_object(Hash.new(0)) do |item, quantities|
        quantities[item.sku] += item.quantity
      end
    end

    private

    def item_count_limit
      limit = Workarea.config.item_count_limit

      if items.size > limit
        errors.add(:base, I18n.t('workarea.order.errors.count_limit', size: limit))
      end
    end
  end
end
