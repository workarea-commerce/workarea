module Workarea
  class Checkout
    module Fraud
      class Analyzer
        attr_reader :checkout

        delegate :order, :user, :payment, :payment_profile, :shipping, :shippings,
            to: :checkout, allow_nil: true
        delegate :fraud_suspected?, to: :order

        def initialize(checkout)
          @checkout = checkout
        end

        def decide!
          begin
            decision = make_decision.tap { |r| r.analyzer = self.class.name }
          rescue => e
            decision = error_decision(e.message)
          ensure
            order.set_fraud_decision!(decision)
          end
        end

        # Gets a decision about the fraudlence of a given checkout
        #
        # @param [Workarea::Checkout] checkout
        #
        # @return [Workarea::Order::FraudDecision]
        #
        def make_decision(checkout = nil)
          raise(NotImplementedError, "#{self.class} must implement the #make_decision method")
        end

        def error_decision(message)
          Workarea::Order::FraudDecision.new(
            decision: :no_decision,
            message: "An error occured during the fraud check: #{message}"
          )
        end
      end
    end
  end
end
