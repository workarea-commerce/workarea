require 'test_helper'

module Workarea
  class TaxTest < TestCase
    def address
      @address ||= Workarea::Address.new(
        country: 'US',
        region: 'PA',
        postal_code: '19106'
      )
    end

    def test_find_rate
      assert_equal(
        0,
        Workarea::Tax.find_rate('001', 10.to_m, address).percentage
      )

      category = create_tax_category(code: '001', rates: [])

      assert_equal(
        0,
        Workarea::Tax.find_rate('001', 10.to_m, address).percentage
      )

      category.rates.create!(percentage: 0.06, country: 'US', region: 'PA')

      assert_equal(
        0.06,
        Workarea::Tax.find_rate('001', 10.to_m, address).percentage
      )
    end
  end
end
