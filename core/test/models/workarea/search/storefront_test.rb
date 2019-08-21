require 'test_helper'

module Workarea
  module Search
    class StorefrontTest < TestCase
      def test_active
        model = create_product(active: false)
        refute(Storefront.new(model).active[:now])

        model.update_attributes!(active: true)
        assert(Storefront.new(model).active[:now])

        model.update_attributes!(active: false)
        release = create_release

        Release.with_current(release.id) do
          model.update_attributes!(active: true)
        end

        model.reload
        results = Storefront.new(model).active
        refute(results[:now])
        assert(results[release.id.to_s])
      end
    end
  end
end
