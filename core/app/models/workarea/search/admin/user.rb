module Workarea
  module Search
    class Admin
      class User < Search::Admin
        def name
          [model.last_name, model.first_name].reject(&:blank?).join(', ')
        end

        def search_text
          UserText.new(model).text
        end

        def keywords
          super + [model.email]
        end

        def jump_to_text
          tmp = model.email.dup
          tmp << " - #{model.name}" unless model.name == model.email
          tmp
        end

        def jump_to_position
          1
        end

        def should_be_indexed?
          !model.system?
        end

        def facets
          super.merge(role: role)
        end

        def as_document
          super.merge(
            total_orders: metrics.orders,
            total_spent: metrics.revenue,
            average_order_value: metrics.average_order_value
          )
        end

        def metrics
          @metrics ||= Metrics::User.find_or_initialize_by(id: model.email)
        end

        private

        def role
          if model.admin?
            'Administrator'
          else
            'Customer'
          end
        end
      end
    end
  end
end
