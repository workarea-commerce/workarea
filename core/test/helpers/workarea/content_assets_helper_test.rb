require 'test_helper'

module Workarea
  class ContentAssetsHelperTest < ViewTest
    def test_returns_the_unoptimized_path_for_a_non_image_asset
      pdf = create_asset(file: pdf_file)
      pdf_url = url_to_content_asset(pdf)
      refute_includes(pdf_url, pdf.optim.url)
    end

    def test_returns_the_optimized_path_for_an_image_asset
      image = create_asset
      image_url = url_to_content_asset(image)
      assert_includes(image_url, image.optim.url)
    end

    def test_prefers_the_provided_asset_host_over_the_default_asset_host
      image = create_asset
      url = url_to_content_asset(image, host: 'http://assets.example.com')
      assert(url.start_with?('http://assets.example.com/'))
    end
  end
end
