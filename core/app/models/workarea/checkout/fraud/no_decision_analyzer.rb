module Workarea
  class Checkout
    module Fraud
      class NoDecisionAnalyzer < Analyzer
        def make_decision
          Workarea::Order::FraudDecision.new(
            decision: :no_decision,
            message: I18n.t('workarea.storefront.fraud.default_message')
          )
        end
      end
    end
  end
end
