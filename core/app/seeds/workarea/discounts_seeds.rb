module Workarea
  class DiscountsSeeds
    def perform
      puts 'Adding discounts...'

      Pricing::Discount::Shipping.create!(
        name: 'Free Ground Shipping',
        amount: 0,
        shipping_service: Shipping::Service.asc(:created_at).first.name,
        promo_codes: ['FREESHIPPING']
      )

      product = Catalog::Product.sample
      Pricing::Discount::Product.create!(
        name: "10% Off #{product.name} when 10 or more are purchased",
        product_ids: [product.id],
        item_quantity: 10,
        amount: 10,
        amount_type: :percent
      )

      category = Catalog::Category.sample
      Pricing::Discount::Category.create!(
        name: "15% Off all products in #{category.name}",
        category_ids: [category.id],
        amount: 15,
        amount_type: :percent,
        promo_codes: ['CATEGORY']
      )

      product = Catalog::Product.sample
      product.details['Brand'] = ['Workarea']
      product.save!

      Pricing::Discount::ProductAttribute.create!(
        name: '10% Off all Workarea Brand products',
        attribute_name: 'Brand',
        attribute_value: 'Workarea',
        amount: 10,
        amount_type: :percent
      )

      category = Catalog::Category.sample
      Pricing::Discount::BuySomeGetSome.create!(
        name: "Buy 2 Get 1 Free from #{category.name}",
        purchase_quantity: 2,
        apply_quantity: 1,
        percent_off: 100,
        category_ids: [category.id],
        promo_codes: ['BUY2GET1']
      )

      product = Catalog::Product.where('variants.0' => { '$exists' => true }).sample
      category = Catalog::Category.sample
      Pricing::Discount::FreeGift.create!(
        name: "Free Gift when purchasing a product from #{category.name}",
        sku: product.skus.sample,
        category_ids: [category.id],
        promo_codes: ['FREEGIFT']
      )

      Pricing::Discount::OrderTotal.create!(
        name: '10% Off Order',
        amount_type: 'percent',
        amount: 10,
        promo_codes: ['10PERCENTOFF']
      )

      category = Catalog::Category.sample
      Pricing::Discount::QuantityFixedPrice.create!(
        name: 'Products, 2 for $25',
        quantity: 2,
        price: 25,
        category_ids: [category.id],
        promo_codes: ['2FOR25']
      )
    end
  end
end
