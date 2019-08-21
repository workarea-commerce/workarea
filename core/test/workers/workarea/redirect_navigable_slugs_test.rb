require 'test_helper'

module Workarea
  class RedirectNavigableSlugsTest < TestCase
    def product_path(id, locale = nil)
      Storefront::Engine.routes.url_helpers.product_path(id: id, locale: locale)
    end

    def test_perform
      set_locales(available: [:en, :es], default: :en, current: :en)
      product = create_product(name: 'Test Product', slug: 'test-product')

      RedirectNavigableSlugs.new.perform(
        product.class.name,
        product.id,
        { 'slug' => ['old-slug', product.slug] }
      )

      redirect = Navigation::Redirect.find_by_path(product_path('old-slug'))
      assert(redirect.present?)
      assert_equal(product_path(product), redirect.destination)

      redirect = Navigation::Redirect.find_by_path(product_path('old-slug', :es))
      assert(redirect.present?)
      assert_equal(product_path(product, :es), redirect.destination)
    end
  end
end
