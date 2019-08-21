require 'test_helper'

module Workarea
  module Search
    class StorefrontTest < TestCase
      def test_active
        model = create_product(active: false)
        refute(Storefront.new(model).active[:now])

        model.update_attributes!(active: true)
        assert(Storefront.new(model).active[:now])

        release_one = create_release
        release_one.as_current { model.update_attributes!(active: false) }

        release_two = create_release
        release_two.as_current { model.update_attributes!(name: 'Foo bar') }

        model.reload
        results = Storefront.new(model).active
        assert(results[:now])
        refute(results[release_one.id.to_s])
        assert(results[release_two.id.to_s])
      end
    end
  end
end
