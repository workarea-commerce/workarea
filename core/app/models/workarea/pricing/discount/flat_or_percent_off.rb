module Workarea
  module Pricing
    class Discount
      module FlatOrPercentOff
        extend ActiveSupport::Concern
        AMOUNT_TYPES = %w(percent flat).freeze

        included do
          # @!attribute amount_type
          #   @return [String] how to treat the amount field, one of {AMOUNT_TYPES}
          #
          field :amount_type, type: String, default: AMOUNT_TYPES.first

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

          # Historically this has been treated like an identifier symbol
          # throughout the admin/UI layer. Ruby 3 + Mongoid will consistently
          # return strings for String-typed fields, so normalize to a symbol.
          def amount_type
            super&.to_sym
          end

          def amount_type=(value)
            super(value.to_s)
          end
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
