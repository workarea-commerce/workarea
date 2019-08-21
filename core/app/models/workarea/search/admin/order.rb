module Workarea
  module Search
    class Admin
      class Order < Search::Admin
        def name
          if payment.address.present?
            "#{payment.address.last_name} #{payment.address.first_name}"
          end
        end

        def search_text
          OrderText.new(model).text
        end

        def keywords
          super + [model.email] + fulfillment.packages.map(&:tracking_number)
        end

        def jump_to_text
          if model.placed?
            "#{model.id} - Placed @ #{model.placed_at.to_s(:short)}"
          else
            "#{model.id} - #{model.status.to_s.titleize}"
          end
        end

        def jump_to_position
          2
        end

        def should_be_indexed?
          model.placed? || model.fraud_suspected?
        end

        def facets
          super.merge(
            order_status: order_status,
            payment_status: payment.status,
            fulfillment_status: fulfillment.status,
            traffic_referrer: traffic_referrer
          )
        end

        def as_document
          super.merge(
            total_price: model.total_price.to_f,
            placed_at: model.placed_at
          )
        end

        def order_status
          model.status
        end

        def traffic_referrer
          source = model.traffic_referrer&.medium || 'direct'
          I18n.t('workarea.order.traffic_referrer')[source]
        end

        def updated_at
          [model, payment, fulfillment].map(&:updated_at).compact.max
        end

        def payment
          @payment ||= Payment.find_or_initialize_by(id: model.id)
        end

        def fulfillment
          @fulfillment ||= Fulfillment.find_or_initialize_by(id: model.id)
        end
      end
    end
  end
end
