require 'test_helper'

module Workarea
  class ApplicationHelperTest < ViewTest
    def test_product_image_url
      product = create_product(slug: 'product')
      image = product.images.build(updated_at: Time.current)
      placeholder = Catalog::ProductPlaceholderImage.new(updated_at: Time.current)

      assert_includes(
        image_url(
          workarea.product_image_placeholder_url(
            :small,
            c: placeholder.updated_at.to_i
          )
        ),
        product_image_url(placeholder, :small)
      )

      assert_includes(
        workarea.dynamic_product_image_url(
          'product',
          image_id: image.id,
          option: nil,
          job: 'small',
          c: image.updated_at.to_i
        ),
        product_image_url(image, :small)
      )

      image.option = 'red'
      assert_includes(
        workarea.dynamic_product_image_url(
          'product',
          'red',
          image.id,
          'small',
          c: image.updated_at.to_i
        ),
        product_image_url(image, :small)
      )
    end

    def test_asset_host_usage
      current_asset_host = Rails.application.config.action_controller.asset_host

      product = create_product(slug: 'product')
      image = product.images.build(updated_at: Time.current)

      Rails.application.config.action_controller.asset_host = 'http://asset.host'
      assert(product_image_url(image, :small).starts_with?('http://asset.host'))

      Rails.application.config.action_controller.asset_host = 'http://asset.host/%d/'
      assert(product_image_url(image, :small).starts_with?('http://asset.host'))
      refute_includes(product_image_url(image, :small), '%d')

      Rails.application.config.action_controller.asset_host = lambda { |*| 'http://lambda.host' }
      assert(product_image_url(image, :small).starts_with?('http://lambda.host'))

      Rails.application.config.action_controller.asset_host = lambda { |*| nil }
      assert_nothing_raised { product_image_url(image, :small) }

    ensure
      Rails.application.config.action_controller.asset_host = current_asset_host
    end
  end
end
