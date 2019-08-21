require 'test_helper'

module Workarea
  module Tax
    class CategoryTest < TestCase
      def test_find_by_code
        category = create_tax_category(code: '001')
        assert_equal(category, Workarea::Tax::Category.find_by_code('001'))
      end

      def test_tiered?
        category = create_tax_category(rates: [])
        refute(category.tiered?)

        category.rates.create!(country: 'US')
        refute(category.tiered?)
        category.rates.delete_all

        category.rates.create!(country: 'US', tier_min: 0, tier_max: 5)
        category.rates.create!(country: 'US', tier_min: 5, tier_max: 7)
        category.rates.create!(country: 'US', tier_min: 7, tier_max: nil)

        assert(category.tiered?)
      end

      def test_find_rate_when_tiered
        category = create_tax_category(rates: [{ country: 'US' }])
        assert_equal(category.rates.first, category.find_rate(3.to_m, 'US', nil, nil))

        category = create_tax_category(code: '002', rates: [])
        first = category.rates.create!(country: 'US', tier_min: 0, tier_max: 4.99)
        second = category.rates.create!(country: 'US', tier_min: 5, tier_max: 6.99)
        third = category.rates.create!(country: 'US', tier_min: 7, tier_max: nil)

        assert_equal(first, category.find_rate(2.to_m, 'US', nil, nil))
        assert_equal(second, category.find_rate(6.to_m, 'US', nil, nil))
        assert_equal(third, category.find_rate(10.to_m, 'US', nil, nil))
      end

      def test_find_rate_location_specific
        category = create_tax_category(code: '002', rates: [])

        philly = category.rates.create!(country: 'US', region: 'PA', postal_code: '19106')
        alberta = category.rates.create!(country: 'CA', region: 'AB')
        british_columbia = category.rates.create!(country: 'CA', region: 'BC')
        _uk = category.rates.create!(country: 'UK')

        assert_nil(category.find_rate(0.to_m, nil, nil, nil))
        assert_nil(category.find_rate(0.to_m, 'CA', nil, nil))
        assert_equal(alberta, category.find_rate(0.to_m, 'CA', 'AB', nil))
        assert_equal(british_columbia, category.find_rate(0.to_m, 'CA', 'BC', nil))
        assert_equal(philly, category.find_rate(0.to_m, 'US', 'PA', '19106'))
        assert_equal(alberta, category.find_rate(0.to_m, 'CA', 'AB', '19106'))
      end
    end
  end
end
