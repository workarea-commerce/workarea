module Workarea
  class Payment
    class Tender
      class StoreCredit < Tender
        def slug
          :store_credit
        end

        def amount=(amount)
          if amount.blank? || profile.blank?
            super
          elsif balance >= amount
            super(amount)
          else
            super(balance)
          end
        end

        private

        def balance
          profile.try(:store_credit) || 0.to_m
        end
      end
    end
  end
end
