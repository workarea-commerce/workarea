module Workarea
  class ShippingServicesSeeds
    def perform
      puts 'Adding shipping services...'

      Shipping::Service.create!(
        name: 'Ground',
        carrier: 'Bogus',
        service_code: '001',
        tax_code: '001',
        rates: [{ price: 7 }]
      )

      Shipping::Service.create!(
        name: 'Second Day',
        carrier: 'Bogus',
        service_code: '002',
        tax_code: '001',
        rates: [{ price: 14 }]
      )

      Shipping::Service.create!(
        name: 'Overnight',
        carrier: 'Bogus',
        service_code: '003',
        tax_code: '001',
        rates: [{ price: 20 }]
      )

      Shipping::Service.create!(
        name: 'New Jersey Ground',
        carrier: 'Bogus',
        service_code: '004',
        tax_code: '001',
        rates: [{ price: 6 }],
        regions: ['NJ'],
        country: 'US'
      )

      Shipping::Service.create!(
        name: 'New Jersey Second Day',
        carrier: 'Bogus',
        service_code: '005',
        tax_code: '001',
        rates: [{ price: 13 }],
        regions: ['NJ'],
        country: 'US'
      )

      Shipping::Service.create!(
        name: 'New Jersey Overnight',
        carrier: 'Bogus',
        service_code: '006',
        tax_code: '001',
        rates: [{ price: 19 }],
        regions: ['NJ'],
        country: 'US'
      )
    end
  end
end
