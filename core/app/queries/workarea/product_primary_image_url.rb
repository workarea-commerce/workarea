module Workarea
  class ProductPrimaryImageUrl
    include ActionView::Helpers::AssetUrlHelper
    include Core::Engine.routes.url_helpers
    include Workarea::ApplicationHelper

    def initialize(product, image_size = :small_thumb)
      @product = product
      @image_size = image_size
    end

    def view_model
      Storefront::ProductViewModel.wrap(@product)
    end

    def url
      return nil unless image.present?
      product_image_url(image, @image_size)
    end

    def path
      return nil unless image.present?
      product_image_path(image, @image_size)
    end

    def image
      view_model.primary_image
    end

    def mounted_core
      self
    end
  end
end
