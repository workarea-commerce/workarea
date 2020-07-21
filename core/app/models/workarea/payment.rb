module Workarea
  class Payment
    include ApplicationDocument

    # The _id field will be the order ID
    field :_id, type: String, default: -> { BSON::ObjectId.new.to_s }

    belongs_to :profile, class_name: 'Workarea::Payment::Profile', optional: true
    embeds_one :address,
      class_name: 'Workarea::Payment::Address',
      as: :addressable

    delegate :first_name, :last_name, :postal_code, to: :address, allow_nil: true
    delegate :saved_card_id, :cvv, to: :credit_card, allow_nil: true
    delegate :default_credit_card, to: :profile, allow_nil: true

    embeds_one :credit_card,
      class_name: "Workarea::Payment::Tender::CreditCard"

    embeds_one :store_credit,
      class_name: "Workarea::Payment::Tender::StoreCredit"

    has_many :refunds,
      class_name: 'Workarea::Payment::Refund',
      inverse_of: :payment

    # Finds the payment order for the given ID and postal code.
    # Both must match the payment order. Used to lookup orders
    # for checking order status anonymously.
    #
    # @param [String] ID
    # @param [String] postal_code
    # @return [Payment, nil]
    #
    def self.lookup(id, postal_code)
      payment = find_or_initialize_by(id: id)
      payment.try(:postal_code) == postal_code ? payment : nil
    end

    # For compatibility with admin features, models must respond to this method
    #
    # @return [String]
    #
    def name
      id
    end

    def store_credit_balance
      profile.try(:store_credit) || 0.to_m
    end

    def saved_credit_cards
      profile.try(:credit_cards) || []
    end

    # TODO in v4 - change this to get transactions by foreign key. Currently,
    # this doesn't return all transactions for this payment if a tender failed
    # validation.
    def transactions
      tenders.map(&:transactions).flatten
    end

    def total
      tenders.map(&:amount).sum || 0.to_m
    end

    def tenders
      Workarea.config.tender_types.flat_map do |type|
        send(type)
      end.compact
    end

    def set_address(attrs)
      build_address unless address
      address.attributes = attrs
      save
    end

    def set_credit_card(attrs)
      build_credit_card unless credit_card
      credit_card.saved_card_id = nil
      credit_card.attributes = attrs.slice(
        *Workarea.config.credit_card_attributes
      )
      save
    end

    def set_store_credit
      build_store_credit unless store_credit
      save
    end

    # Adjust tender amounts to meet an order total. Used
    # in checkout when updating payment.
    #
    # @param [Money] total
    # @return [Boolean] whether the payment is saved
    #
    def adjust_tender_amounts(new_total)
      set_store_credit if store_credit_balance > 0.to_m

      tenders.each do |tender|
        tender.amount = new_total

        # tender.amount could have been changed, e.g. if the store credit
        # balance is lower
        new_total -= tender.amount
      end

      save
    end

    # Remove the current card for the payment.
    # Used for clearing out a card when updating payment
    # so another payment option could be selected
    #
    def clear_credit_card
      self.credit_card = nil
    end

    # Whether or not the order is purchasable. This is defined as the tenders
    # amount equals the amount passed in (the {Order}#total). Used in checkout
    # to determine whether we should try to purchase the order.
    #
    # If the order is not purchasable then all relavant validation errors
    # will be added to the order.
    #
    # @param [Money] total_amount
    # @return [Boolean]
    #
    def purchasable?(total_amount)
      tenders.all?(&:valid?) && tendered_amount == total_amount
    end

    def tendered_amount
      tenders.map(&:amount).sum.to_m
    end

    def credit_card?
      credit_card.present?
    end

    def store_credit?
      store_credit.present?
    end

    def authorize!(options = {})
      transactions = tenders.map { |t| t.build_transaction(action: 'authorize') }
      perform_operation(transactions, options)
    end

    def purchase!(options = {})
      transactions = tenders.map { |t| t.build_transaction(action: 'purchase') }
      perform_operation(transactions, options)
    end

    def status
      calculators = Workarea.config.payment_status_calculators.map(&:constantize)
      StatusCalculator.new(calculators, self).result
    end

    private

    def perform_operation(transactions, options)
      operation = Operation.new(transactions, options)
      operation.complete!
      operation.errors.each do |message|
        errors.add(:base, message)
      end

      operation.success?
    end
  end
end
