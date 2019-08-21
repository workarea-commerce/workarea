module Workarea
  class Payment
    module Status
      class NotApplicable
        include StatusCalculator::Status

        def in_status?
          order.tenders.empty?
        end
      end

      class Pending
        include StatusCalculator::Status

        def in_status?
          order.transactions.map(&:success?).empty?
        end
      end

      class Authorized
        include StatusCalculator::Status

        def in_status?
          order.tenders.all? do |tender|
            tender.authorized_amount == tender.amount &&
              tender.captured_amount == 0
          end
        end
      end

      class Captured
        include StatusCalculator::Status

        def in_status?
          order.tenders.all? do |tender|
            tender.captured_amount == tender.amount &&
              tender.refunded_amount == 0
          end
        end
      end

      class PartiallyCaptured
        include StatusCalculator::Status

        def in_status?
          order.tenders.any? do |tender|
            tender.captured_amount > 0 &&
              tender.refunded_amount == 0
          end
        end
      end

      class Refunded
        include StatusCalculator::Status

        def in_status?
          order.tenders.all? do |tender|
            tender.refunded_amount == tender.amount
          end
        end
      end

      class PartiallyRefunded
        include StatusCalculator::Status

        def in_status?
          order.tenders.any? do |tender|
            tender.refunded_amount > 0
          end
        end
      end
    end
  end
end
