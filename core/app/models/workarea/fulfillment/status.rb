module Workarea
  class Fulfillment
    module Status
      class NotAvailable
        include StatusCalculator::Status

        def in_status?
          !model.persisted?
        end
      end

      class Open
        include StatusCalculator::Status

        def in_status?
          model.items.blank? || model.events.blank?
        end
      end

      class Canceled
        include StatusCalculator::Status

        def in_status?
          model.items.all? { |i| i.quantity_canceled >= i.quantity }
        end
      end

      class Shipped
        include StatusCalculator::Status

        def in_status?
          model.items.all? do |item|
            (item.quantity_shipped + item.quantity_canceled) >= item.quantity
          end
        end
      end

      class PartiallyShipped
        include StatusCalculator::Status

        def in_status?
          model.items.any? { |i| i.quantity_shipped > 0 }
        end
      end

      class PartiallyCanceled
        include StatusCalculator::Status

        def in_status?
          model.items.any? { |i| i.quantity_canceled > 0 }
        end
      end
    end
  end
end
