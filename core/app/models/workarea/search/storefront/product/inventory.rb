module Workarea
  module Search
    class Storefront
      class Product
        module Inventory
          def inventory
            @inventory ||= Workarea::Inventory::Collection.new(skus)
          end

          def skus_with_displayable_inventory
            @skus_with_displayable_inventory ||=
              if skus.present?
                inventory.select(&:displayable?).map(&:id)
              else
                []
              end
          end

          def inventory_score
            if inventory.available_to_sell.zero? && displayable_when_out_of_stock?
              0
            else
              1
            end
          end

          def displayable_when_out_of_stock?
            inventory.records.any?(&:displayable_when_out_of_stock?)
          end
        end
      end
    end
  end
end
