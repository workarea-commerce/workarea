require 'test_helper'

module Workarea
  class ProductPrimaryImageUrlTest < Workarea::TestCase

    setup :setup_product

    def setup_product
      @product = create_product
    end

    def test_returns_small_thumb_by_default
      url = ProductPrimaryImageUrl.new(@product).url
      assert_includes(url, 'small_thumb')
    end

    def test_returns_the_image_url_for_specified_size
      url = ProductPrimaryImageUrl.new(@product, :medium_thumb).url
      assert_includes(url, 'medium_thumb')
    end
  end
end
