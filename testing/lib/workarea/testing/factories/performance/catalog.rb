module Workarea
  module Factories
    module Performance
      module Catalog
        Factories.add(self)

        def create_complex_variant
          @sku_counter ||= 0

          details =
            if @sku_counter < variant_details.length
              variant_details[@sku_counter]
            else
              variant_details[@sku_counter % variant_details.length]
            end

          @sku_counter += 1

          attributes = {
            sku: "sku#{@sku_counter}",
            details: details
          }

          create_pricing_sku(
            id: attributes[:sku],
            msrp: (rand * 215.0).round(2),
            prices: [
              { regular: (rand * 101.1).round(2), sale: (rand * 98.6).round(2), min_quantity: 1 },
              { regular: (rand * 101.1).round(2), sale: (rand * 98.6).round(2), min_quantity: 2 },
              { regular: (rand * 101.1).round(2), sale: (rand * 98.6).round(2), min_quantity: 5 }
            ]
          )

          create_inventory(
            id: attributes[:sku],
            policy: 'standard',
            available: (rand * 100).round + 10,
            reserve: (rand * 5).round
          )

          Workarea::Catalog::Variant.new(attributes)
        end

        def create_complex_product(overrides = {})
          attributes = { variants: [], details: {} }.merge(overrides)

          product = create_product(attributes)
          product.variants = Array.new(100) { create_complex_variant } unless product.variants.any?

          colors = product.variants.flat_map { |v| v.fetch_detail('Color') }.uniq!
          sizes = product.variants.flat_map { |v| v.fetch_detail('Size') }.uniq!
          materials = product.variants.flat_map { |v| v.fetch_detail('Material') }.uniq!

          colors.each do |color|
            product.images.build(image: product_image_file_path, option: color)
          end

          product.filters = { 'Color' => colors, 'Size' => sizes, 'Material' => materials }
          product.save
          product
        end

        private

        def variant_details
          return @variant_details if defined?(@variant_details)
          details = {
            'Color' => %w(Red Orange Yellow Green Blue Indigo Violet),
            'Size' => %w(X-Small Small Medium Large X-Large XX-Large),
            'Material' => %w(Cotton Wool Silk Polyester)
          }

          @variant_details = []

          details['Color'].each do |color|
            details['Size'].each do |size|
              details['Material'].each do |material|
                @variant_details << {
                  'Color' => [color],
                  'Size' => [size],
                  'Material' => [material]
                }
              end
            end
          end

          @variant_details.shuffle
        end
      end
    end
  end
end
