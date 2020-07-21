module Workarea
  class Checkout
    attr_reader :order, :user

    def initialize(order, user = nil)
      @order = order
      @user = user
    end

    # Classes used to update the data and check status on the checkout.
    #
    # @return [Array<Class>]
    #
    def steps
      @steps ||= Workarea.config.checkout_steps.map(&:constantize)
    end

    # The current email for this checkout. Used to find
    # payment profile.
    #
    # @return [String, nil]
    #
    def email
      if user.present?
        user.email
      elsif order.email.present?
        order.email
      end
    end

    def shipping
      return nil unless order.requires_shipping?
      shippings.first
    end

    def shippings
      return [] unless order.requires_shipping?
      @shippings ||= Shipping.by_order(order.id).to_a.presence ||
                     [Shipping.new(order_id: order.id)]
    end

    # The inventory transaction for this checkout. Uses serialized
    # representation of transaction inventory requirements.
    #
    # @return [Inventory::Transaction]
    #
    def inventory
      @inventory ||= Inventory::Transaction.from_order(
        order.id,
        order.sku_quantities
      )
    end

    # The payment for this checkout.
    #
    # @return [Payment]
    #
    def payment
      @payment ||= Payment.find_or_initialize_by(id: order.id)
    end

    def payment_profile
      return nil if email.blank?

      @payment_profile ||= Payment::Profile.lookup(
        PaymentReference.new(user, order)
      )
    end

    def payment_collection
      @payment_collection ||= CollectPayment.new(self)
    end

    # Whether the checkout has changed users. Determined by
    # checking the current user for the {Checkout} against the
    # user set on the order
    #
    # @return [Boolean]
    #
    def user_changed?
      user.present? && user.id.to_s != order.user_id
    end

    # Starts checkout and resets the order to be setup for
    # the passed user.
    #
    # If a {User} is passed, checkout is autocompleted as far as
    # possible based on that {User}'s saved data.
    #
    # If the symbol `:guest`, a blank checkout will be started.
    #
    # @param [User, :guest]
    # @return [void]
    #
    def start_as(user)
      reset!

      unless user == :guest
        @user = user
        order.user_id = user.id
        update(auto_complete.params)
      end

      payment.profile_id = payment_profile.try(:id)
      order.touch_checkout!
    end

    # Reset this checkout's personal information. This is called when restarting
    # checkout, such as after cookies expire or starting checkout as a guest.
    #
    # @return [void]
    #
    def reset!
      @user = nil
      order.reset_checkout!

      Shipping.where(order_id: order.id).destroy_all
      @shippings = nil

      Payment.where(id: order.id).destroy_all
      @payment = nil
    end

    # Transfer order to passed user. Checkout is then
    # autocompleted as far as possible based on the {User}'s
    # save data without overriding information already
    # provided in checkout.
    #
    # @param [User]
    # @return [void]
    #
    def continue_as(user)
      @user = user
      order.user_id = user.id
      payment.profile_id = payment_profile.try(:id)

      steps.each do |step|
        step_instance = step.new(self)

        unless step_instance.complete?
          step_instance.update(auto_complete.params)
        end
      end

      order.touch_checkout!
    end

    # Complete checkout update. Updates all steps/data related
    # to the checkout. This includes:
    #
    # This method does not place the order and makes no
    # guarantees about the updates succeeding.
    #
    # Used in auto completing an order for a logged in user.
    #
    # @param [Hash] parameters for updating
    # @return [self]
    #
    def update(params = {})
      steps.each { |s| s.new(self).update(params) }
    end

    # Whether this checkout needs any further information
    # to place the order. Used to determine whether to
    # redirect the user to the review checkout step.
    #
    # @return [Boolean]
    #
    def complete?
      order.purchasable? && steps.map { |s| s.new(self) }.all?(&:complete?)
    end

    # This is the authoritative method to place an order.
    # This includes telling payment and inventory to purchase
    # the order, and aborting/rolling back if they fail.
    #
    # Used in the checkouts controller to place the order.
    #
    # @return [Boolean] whether the order was successfully placed
    #
    def place_order
      return false unless complete?
      return false unless shippable?
      return false unless payable?

      fraud_analyzer.decide!
      return false if fraud_analyzer.fraud_suspected?

      inventory.purchase
      return false unless inventory.captured?

      unless payment_collection.purchase
        inventory.rollback
        return false
      end

      result = order.place
      place_order_side_effects if result
      result
    end

    # Whether this checkout is valid to ship
    #
    # @return [Boolean]
    #
    def shippable?
      !order.requires_shipping? ||
        shippings.all? { |s| ShippingOptions.new(order, s).valid? }
    end

    # Whether this checkout is valid to collect payment on.
    #
    # @return [Boolean]
    #
    def payable?
      payment.valid? && payment_collection.valid?
    end

    # Recalculate the amounts on tenders if payment is persisted.
    #
    # @return [Boolean, nil]
    #
    def adjust_tender_amounts!
      return unless payment.persisted?
      payment.adjust_tender_amounts(order.total_price)
    end

    private

    def auto_complete
      @auto_complete ||= Checkout::AutoComplete.new(
        order,
        payment,
        user
      )
    end

    def place_order_side_effects
      CreateFulfillment.new(order).perform
    end

    def fraud_analyzer
      @fraud_analyzer ||= Workarea.config.fraud_analyzer.constantize.new(self)
    end
  end
end
