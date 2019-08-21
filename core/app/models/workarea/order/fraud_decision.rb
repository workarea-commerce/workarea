module Workarea
  class Order
    class FraudDecision
      include ApplicationDocument

      embedded_in :order, class_name: 'Workarea::Order'

      field :decision, type: Symbol, default: :no_decision
      field :analyzer, type: String
      field :message, type: String
      field :response, type: String

      def declined?
        decision == :declined
      end
    end
  end
end
