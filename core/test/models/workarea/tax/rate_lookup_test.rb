require 'test_helper'

module Workarea
  module Tax
    class RateLookupTest < TestCase
      def test_find_rate_when_tiered
        category = create_tax_category(rates: [{ country: Country['US'] }])
        rate = category.rates.first
        best_rate = RateLookup.find_best_rate(
          category: category,
          price: 3.to_m,
          country: Country['US']
        )

        assert_equal(rate, best_rate)

        category = create_tax_category(code: '002', rates: [])
        first = category.rates.create!(country: Country['US'], tier_min: 0, tier_max: 4.99)
        second = category.rates.create!(country: Country['US'], tier_min: 5, tier_max: 6.99)
        third = category.rates.create!(country: Country['US'], tier_min: 7, tier_max: nil)

        assert_equal(
          first,
          RateLookup.find_best_rate(
            category: category,
            price: 2.to_m,
            country: Country['US']
          )
        )
        assert_equal(
          second,
          RateLookup.find_best_rate(
            category: category,
            price: 6.to_m,
            country: Country['US']
          )
        )
        assert_equal(
          third,
          RateLookup.find_best_rate(
            category: category,
            price: 10.to_m,
            country: Country['US']
          )
        )
      end

      def test_find_rate_location_specific
        category = create_tax_category(code: '002', rates: [])

        philly = category.rates.create!(country: Country['US'], region: 'PA', postal_code: '19106')
        alberta = category.rates.create!(country: Country['CA'], region: 'AB')
        british_columbia = category.rates.create!(country: Country['CA'], region: 'BC')
        _uk = category.rates.create!(country: 'UK')

        assert_nil(RateLookup.find_best_rate(price: 0.to_m, category: category))

        ca = category.rates.create!(country: Country['CA'])

        assert_equal(
          ca,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['CA']
          )
        )
        assert_equal(
          british_columbia,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['CA'],
            region: 'BC'
          )
        )
        assert_equal(
          philly,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'PA',
            postal_code: '19106'
          )
        )
        assert_equal(
          alberta,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['CA'],
            region: 'AB',
            postal_code: '19106'
          )
        )
      end

      def test_find_most_specific_rate
        category = create_tax_category(code: '002', rates: [])
        us = category.rates.create!(country: Country['US'], percentage: 0.005)
        kansas =
          category.rates.create!(
            country: Country['US'],
            region: 'KS',
            percentage: 0.0875
          )
        atchinson =
          category.rates.create!(
            country: Country['US'],
            region: 'KS',
            postal_code: '66002',
            percentage: 0.065
          )
        kansas_city =
          category.rates.create!(
            country: Country['US'],
            region: 'KS',
            postal_code: '64030',
            percentage: 0.056
          )
        olde_city = category.rates.create(
          country: Country['US'],
          region: 'PA',
          postal_code: '19106-2701',
          percentage: 0.02
        )
        philly = category.rates.create(
          country: Country['US'],
          region: 'PA',
          postal_code: '19106',
          percentage: 0.01
        )

        assert_equal(
          atchinson,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'KS',
            postal_code: '66002'
          )
        )
        assert_equal(
          kansas_city,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'KS',
            postal_code: '64030'
          )
        )
        assert_equal(
          kansas,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'KS'
          )
        )
        assert_equal(
          kansas,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'KS',
            postal_code: '60000'
          )
        )
        assert_equal(
          us,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'NJ',
            postal_code: '07208'
          )
        )
        assert_equal(
          philly,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'PA',
            postal_code: '19106'
          )
        )
        assert_equal(
          olde_city,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'PA',
            postal_code: '19106-2701'
          )
        )
        assert_equal(
          philly,
          RateLookup.find_best_rate(
            category: category,
            price: 0.to_m,
            country: Country['US'],
            region: 'PA',
            postal_code: '19106-6789'
          )
        )
      end
    end
  end
end
