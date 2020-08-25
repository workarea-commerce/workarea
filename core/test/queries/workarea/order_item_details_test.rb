require 'test_helper'

module Workarea
  class OrderItemDetailsTest < Workarea::TestCase
    def test_find_bang_without_product
      assert_raises OrderItemDetails::InvalidPurchase do
        OrderItemDetails.find!('SKU1')
      end
    end

    def test_find_without_product
      assert_nil(OrderItemDetails.find('SKU1'))
    end

    def test_fulfillment
      product = create_product(variants: [{ sku: 'SKU', regular: 5.00 }])
      assert_equal('shipping', OrderItemDetails.find('SKU').to_h[:fulfillment])

      sku = create_fulfillment_sku(id: 'SKU', policy: 'download', file: product_image_file_path)
      assert_equal('download', OrderItemDetails.find('SKU').to_h[:fulfillment])
    end

    def test_to_h
      product = create_product(id: "840B898080", variants: [{ sku: 'SKU', regular: 5.00 }])
      # we lose time precision on created_at/updated_at when storing in the database
      # reload the product to truncate the timestamps
      product.reload
      details = OrderItemDetails.find!('SKU').to_h

      assert_equal("840B898080", details[:product_id])
      assert_equal(product.as_document, details[:product_attributes])
    end


    def test_shared_sku_products
      product = create_product(id: "840B898080", variants: [{ sku: 'SKU', regular: 5.00 }])
      product.reload
      Catalog::Product.create!(id: "840B898081", name: "Product Test", variants: [{ sku: "SKU" }])

      details = OrderItemDetails.find!('SKU', product_id: "840B898080").to_h

      assert_equal("840B898080", details[:product_id])
      assert_equal(product.as_document, details[:product_attributes])

      product = Catalog::Product.find("840B898081")
      details = OrderItemDetails.find!('SKU', product_id: "840B898081").to_h

      assert_equal("840B898081", details[:product_id])
      assert_equal(product.as_document, details[:product_attributes])
    end
  end
end
