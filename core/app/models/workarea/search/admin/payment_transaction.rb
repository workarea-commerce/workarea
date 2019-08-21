module Workarea
  module Search
    class Admin
      class PaymentTransaction < Search::Admin
        def status
          if model.canceled?
            'canceled'
          elsif model.success?
            'success'
          else
            'failure'
          end
        end

        def keywords
          super + [model.payment_id]
        end

        def auth_status
          return nil unless model.authorize?

          if model.captured_amount.zero?
            'pending_capture'
          elsif model.captured_amount > 0 &&
                  model.captured_amount < model.amount
            'partially_captured'
          elsif model.captured_amount == model.amount
            'captured'
          end
        end

        def facets
          super.merge(
            auth_status: auth_status,
            tender_type: tender_type,
            transaction: model.action
          )
        end

        def name
          nil
        end

        def search_text
          nil
        end

        def jump_to_text
          nil
        end

        def jump_to_search_text
          nil
        end

        def jump_to_position
          nil
        end

        private

        def tender_type
          model.tender.class.name.demodulize.underscore
        end
      end
    end
  end
end
