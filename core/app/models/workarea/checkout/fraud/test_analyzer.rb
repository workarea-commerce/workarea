module Workarea
  class Checkout
    module Fraud
      class TestAnalyzer < Analyzer
        def make_decision
          if order.email == "decline@workarea.com"
            Workarea::Order::FraudDecision.new(
              decision: :declined,
              message: "Forced test fraud decline."
            )
          elsif order.email == "approved@workarea.com"
            Workarea::Order::FraudDecision.new(
              decision: :approved,
              message: "Forced test fraud approval."
            )
          else
            Workarea::Order::FraudDecision.new(
              decision: :no_decision,
              message: "Workarea default fraud check. Automatic no decision."
            )
          end
        end
      end
    end
  end
end
