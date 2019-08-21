module Workarea
  module PriceAdjustmentExtension
    def adjusting(*args)
      PriceAdjustmentSet.new(self).adjusting(*args)
    end

    def discounts
      PriceAdjustmentSet.new(self).discounts
    end

    def sum
      PriceAdjustmentSet.new(self).sum
    end

    def reduce_by_description(*args)
      PriceAdjustmentSet.new(self).reduce_by_description(*args)
    end
  end
end
