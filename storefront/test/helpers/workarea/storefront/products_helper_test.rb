require 'test_helper'

module Workarea
  module Storefront
    class ProductsHelperTest < ViewTest
      include Workarea::Storefront::Engine.routes.url_helpers

      def test_truncated_product_description
        description = <<-eos
          Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do
          eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad
          minim veniam, quis nostrud exercitation ullamco laboris nisi ut
          aliquip ex ea commodo consequat. Duis aute irure dolor in
          reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
          pariatur. Excepteur sint occaecat cupidatat non proident, sunt in
          culpa qui officia deserunt mollit anim id est laborum.
        eos

        model = create_product(description: description)
        view_model = ProductViewModel.wrap(model, via: '1234')

        result = truncated_product_description(view_model, 'Read More')
        assert(description.length > result.length)

        result = truncated_product_description(view_model, 'Read More')
        assert_match(/#{model.slug}\?via\=1234\#description/, result)
      end

      def test_option_selection_url_for
        product = ProductViewModel.wrap(create_product(template: 'option_thumbnails'))
        selection = 'Blue'
        option = ProductViewModel::Option.new(product, product.slug, ['Blue'])
        params[:via] = 'foo'

        url = option_selection_url_for(product, option, selection).with_indifferent_access

        assert_equal(product.slug, url[:id])
        assert_equal('Blue', url[option.slug])
        assert_equal('foo', url[:via])
      end
    end
  end
end
