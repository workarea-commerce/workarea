require 'test_helper'

module Workarea
  module Tax
    class RateTest < TestCase
      def test_search
        category = create_tax_category(rates: [])

        pa_region    = category.rates.create!(country: Country['US'], region: 'PA')
        zip_code     = category.rates.create!(country: Country['US'], postal_code: '19106')
        canada       = category.rates.create!(country: Country['CA'])
        other        = category.rates.create!(country: Country['US'], region: 'NJ', postal_code: '07001')

        # region match
        results = Rate.search('PA').to_a
        assert_includes(results, pa_region)
        refute_includes(results, zip_code)
        refute_includes(results, canada)

        # postal code match
        results = Rate.search('191').to_a
        assert_includes(results, zip_code)
        refute_includes(results, pa_region)

        # country match
        results = Rate.search('CA').to_a
        assert_includes(results, canada)

        # no match
        results = Rate.search('NOPE').to_a
        assert_empty(results)
      end
    end
  end
end
