module Workarea
  module Reports
    class LowInventory
      include Report

      self.reporting_class = Workarea::Inventory::Sku
      self.sort_fields = %w(policy available backordered backordered_until purchased updated_at)

      def aggregation
        [filter_sellable, project_used_fields]
      end

      def filter_sellable
        {
          '$match' => {
            'sellable' => { '$lt' => Workarea.config.low_inventory_threshold }
          }
        }
      end

      def project_used_fields
        {
          '$project' => {
            '_id' => 1,
            'available' => 1,
            'purchased' => 1,
            'backordered' => 1,
            'backordered_until' => 1,
            'policy' => 1,
            'updated_at' => 1
          }
        }
      end
    end
  end
end
