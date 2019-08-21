module Workarea
  module Pricing
    class Discount
      # This class coordinates with a {FlatOrPercentOff} discount to calculate
      # how much should be given against a certin amount off.
      #
      class AmountCalculator
        delegate :amount_type, :amount, to: :@discount

        def initialize(discount)
          @discount = discount
        end

        # Whether this calculator is based on percent
        # off the price.
        #
        # @return [Boolean]
        #
        def percent?
          amount_type == :percent
        end

        # Whether this calculator is based on a flat amount
        # off the price.
        #
        # @return [Boolean]
        #
        def flat?
          amount_type == :flat
        end

        # The percent representation of the amount off.
        #
        # @return [Float]
        #
        def percent
          amount / 100
        end

        # Calculate the amount off of the passed price.
        #
        # @param [Money] the price to be discounted
        # @return [Money]
        #
        def calculate(price, quantity = 1)
          if percent?
            price * quantity * percent
          elsif price.to_m < amount.to_m
            price * quantity
          else
            amount.to_m * quantity
          end
        end
      end
    end
  end
end
