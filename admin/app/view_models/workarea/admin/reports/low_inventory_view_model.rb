module Workarea
  module Admin
    module Reports
      class LowInventoryViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            sku = skus.detect { |s| s.id.to_s == result['_id'] }
            OpenStruct.new({ sku: sku }.merge(result))
          end
        end

        def skus
          @skus ||= Inventory::Sku.any_in(
            id: model.results.map { |r| r['_id'] }
          ).to_a
        end
      end
    end
  end
end
