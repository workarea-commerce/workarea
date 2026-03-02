module Workarea
  class Order
    class FraudDecision
      include ApplicationDocument

      embedded_in :order, class_name: 'Workarea::Order', touch: false

      field :decision, type: String, default: 'no_decision'
      field :analyzer, type: String
      field :message, type: String
      field :response, type: String

      # Historically treated as an identifier symbol in code/tests. Mongoid
      # stores this as a String field, so normalize to a symbol.
      def decision
        super&.to_sym
      end

      def decision=(value)
        super(value.to_s)
      end

      def declined?
        decision.to_s == 'declined'
      end
    end
  end
end
