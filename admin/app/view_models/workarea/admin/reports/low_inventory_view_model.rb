module Workarea
  module Admin
    module Reports
      class LowInventoryViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            OpenStruct.new({ sku: skus[result['_id']] }.merge(result))
          end
        end

        def skus
          @skus ||= Inventory::Sku.any_in(id: model.results.map { |r| r['_id'] }).to_lookup_hash
        end
      end
    end
  end
end
