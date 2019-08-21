module Workarea
  class PriceAdjustmentSet < Array
    def select(*args)
      self.class.new(super)
    end

    def reject(*args)
      self.class.new(super)
    end

    def adjusting(type)
      select { |a| a.price == type }
    end

    def sum
      super(&:amount).to_m
    end

    def discounts
      select(&:discount?)
    end

    def +(val)
      self.class.new(to_a + val.to_a)
    end

    def reduce_by_description(type)
      amounts = adjusting(type).reduce({}) do |memo, adjustment|
        memo[adjustment.description] ||= 0.to_m
        memo[adjustment.description] += adjustment.amount
        memo
      end

      self.class.new(
        amounts.keys.map do |description|
          PriceAdjustment.new(
            description: description,
            amount: amounts[description]
          )
        end
      )
    end

    def taxable_share_for(adjustment)
      return 0.to_m if taxable_total.zero?

      discount_share = adjustment.amount / taxable_total
      discount_amount = discount_total * discount_share
      adjustment.amount - discount_amount
    end

    def grouped_by_parent
      each_with_object({}) do |adjustment, memo|
        memo[adjustment._parent] ||= PriceAdjustmentSet.new
        memo[adjustment._parent] << adjustment
      end
    end

    private

    def taxable_total
      reject { |a| a.discount? || a.data['tax_code'].blank? }.sum(&:amount).to_m
    end

    def discount_total
      discounts.sum(&:amount).to_m.abs
    end
  end
end
