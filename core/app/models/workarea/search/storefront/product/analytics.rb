module Workarea
  module Search
    class Storefront
      class Product
        module Analytics
          def orders_score
            calculate_sorting_score(:orders)
          end

          def views_score
            calculate_sorting_score(:views)
          end

          private

          def calculate_sorting_score(field)
            Metrics::ProductByWeek
              .by_product(model.id)
              .since(Workarea.config.sorting_score_ttl.ago)
              .score(field)
          end
        end
      end
    end
  end
end
