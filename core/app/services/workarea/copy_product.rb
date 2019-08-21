module Workarea
  class CopyProduct
    def initialize(product, attrs = {})
      @product = product
      @attributes = Workarea.config.product_copy_default_attributes.merge(attrs)
    end

    def perform
      product_copy = @product.clone
      product_copy.assign_attributes(@attributes)
      product_copy.copied_from = @product

      existing_product = Catalog::Product.find(product_copy.id) rescue nil

      if existing_product.present?
        product_copy.errors.add(
          :id,
          I18n.t('workarea.errors.messages.must_be_unique')
        )
      else
        product_copy.save!
      end

      product_copy
    end
  end
end
