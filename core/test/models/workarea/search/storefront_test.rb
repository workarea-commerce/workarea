require 'test_helper'

module Workarea
  module Search
    class StorefrontTest < TestCase
      def test_active
        model = create_product(active: false)
        refute(Storefront.new(model).active[:now])

        model.update!(active: true)
        assert(Storefront.new(model).active[:now])
      end
    end
  end
end
