module Workarea
  module Pricing
    class Discount
      module FlatOrPercentOff
        extend ActiveSupport::Concern
        AMOUNT_TYPES = %i(percent flat)

        included do
          # @!attribute amount_type
          #   @return [Symbol] how to treat the amount field, one of {AMOUNT_TYPES}
          #
          field :amount_type, type: Symbol, default: AMOUNT_TYPES.first

          # @!attribute amount
          #   @return [Float] the amount of the discount
          #
          field :amount, type: Float

          validates :amount_type, presence: true, inclusion: AMOUNT_TYPES
          validates :amount,
            presence: true,
            numericality: { greater_than: 0, allow_blank: true },
            unless: :percent?

          validates :amount,
            numericality: {
              greater_than: 0,
              less_than_or_equal_to: 100,
              allow_blank: true
            },
            if: :percent?

          delegate :percent?, to: :amount_calculator
        end

        # The calculator used to calculate how much this discount should
        # apply to the order.
        #
        # @return [AmountCalculator]
        #
        def amount_calculator
          @amount_calculator ||= AmountCalculator.new(self)
        end
      end
    end
  end
end
