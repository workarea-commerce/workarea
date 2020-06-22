require 'test_helper'

module Workarea
  class DragonflyJobFetchURLTest < TestCase
    def test_fail_early_on_misconfigured_proxy
      product = create_product

      stub_request(:any, 'http://via.placeholder.com/350x150')
        .to_return(
          status: 403,
          body: Core::Engine.root.join(
            'app/assets/images/workarea/core/icon.svg'
          ).read,
          headers: { 'X-Squid-Error' => 'ERR_ACCESS_DENIED 0' }
        )

      assert_raises(Dragonfly::Job::FetchUrl::ProxyError) do
        product.images.create!(
          image_url: 'http://via.placeholder.com/350x150'
        )
      end
    end
  end
end
