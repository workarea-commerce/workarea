module Workarea
  module Admin
    module Reports
      class SalesByDiscountViewModel < ApplicationViewModel
        def results
          @results ||= model.results.map do |result|
            discount = discounts.detect { |p| p.id.to_s == result['_id'] }
            OpenStruct.new({ discount: discount }.merge(result))
          end
        end

        def discounts
          @discounts ||= Pricing::Discount.any_in(
            id: model.results.map { |r| r['_id'] }
          ).to_a
        end
      end
    end
  end
end
