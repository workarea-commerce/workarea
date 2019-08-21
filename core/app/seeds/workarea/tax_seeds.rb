module Workarea
  class TaxSeeds
    def perform
      puts 'Adding tax rates...'

      category = Tax::Category.create!(
        name: 'Sales Tax',
        code: '001'
      )

      category.rates.create!(
        region_percentage: 0.07,
        country: 'US',
        region: 'PA'
      )

      category.rates.create!(
        region_percentage: 0.08,
        country: 'US',
        region: 'NY',
        tier_min: 0,
        tier_max: 200
      )

      category.rates.create!(
        region_percentage: 0.09,
        country: 'US',
        region: 'NY',
        tier_min: 200.01
      )
    end
  end
end
