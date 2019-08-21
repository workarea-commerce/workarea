module Workarea
  module Admin
    module Reports
      class SalesByDiscountViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            OpenStruct.new({ discount: discounts[result['_id']] }.merge(result))
          end
        end

        def discounts
          @discounts ||= Pricing::Discount.any_in(id: model.results.map { |r| r['_id'] }).to_lookup_hash
        end
      end
    end
  end
end
