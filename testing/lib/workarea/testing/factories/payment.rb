module Workarea
  module Factories
    module Payment
      Factories.add(self)

      def create_payment(overrides = {})
        attributes = factory_defaults(:payment).merge(overrides)
        Workarea::Payment.create!(attributes)
      end

      def create_payment_profile(overrides = {})
        attributes = factory_defaults(:payment_profile).merge(overrides)
        Workarea::Payment::Profile.create!(attributes)
      end

      def create_saved_credit_card(overrides = {})
        attributes = factory_defaults(:saved_credit_card).merge(overrides)
        Workarea::Payment::SavedCreditCard.create!(attributes)
      end

      def create_transaction(overrides = {})
        attributes = factory_defaults(:transaction).merge(overrides)
        Workarea::Payment::Transaction.create!(attributes)
      end

      def capture_order(order)
        payment = Workarea::Payment.find(order.id)
        capture = Workarea::Payment::Capture.new(
          payment: payment,
          amounts: payment.tenders.reduce({}) { |m, t| m.merge(t.id => t.capturable_amount) }
        )

        capture.complete!
      end

      def next_year
        1.year.from_now.year
      end
    end
  end
end
