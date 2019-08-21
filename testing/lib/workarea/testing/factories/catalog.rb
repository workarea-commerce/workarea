module Workarea
  module Factories
    module Catalog
      Factories.add(self)

      def create_category(overrides = {})
        attributes = factory_defaults(:category).merge(overrides)
        Workarea::Catalog::Category.create!(attributes)
      end

      def create_product(overrides = {})
        attributes = factory_defaults(:product).merge(overrides)

        Workarea::Catalog::Product.new(attributes.except(:variants)).tap do |product|
          product.id = attributes[:id] if attributes[:id].present?

          if attributes[:variants].present?
            attributes[:variants].each do |attrs|
              pricing_attrs = [
                :regular, :sale, :msrp, :on_sale,
                :tax_code, :discountable
              ]

              sku = Workarea::Pricing::Sku.find_or_create_by(id: attrs[:sku])
              sku.attributes = attrs.slice(
                :on_sale,
                :tax_code,
                :discountable
              )
              sku.prices.build(attrs.slice(:regular, :sale, :msrp))
              sku.save!

              variant_attrs = attrs.except(*pricing_attrs)
              product.variants.build(variant_attrs)
            end
          end

          product.save!
        end
      end

      def create_product_placeholder_image(overrides = {})
        attributes = factory_defaults(:product_placeholder_image)
        Workarea::Catalog::ProductPlaceholderImage.create!(
          attributes.merge(overrides)
        )
      end

      def product_image_file_path
        Factories::Catalog.product_image_file_path
      end

      def product_image_file
        Factories::Catalog.product_image_file
      end

      def self.product_image_file_path
        Testing::Engine.root.join('lib', 'workarea', 'testing', 'product_image.jpg')
      end

      def self.product_image_file
        IO.read(product_image_file_path)
      end
    end
  end
end
