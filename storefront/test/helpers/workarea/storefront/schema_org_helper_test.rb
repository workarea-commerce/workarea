require 'test_helper'

module Workarea
  module Storefront
    class SchemaOrgHelperTest < ViewTest
      include NavigationHelper
      include Engine.routes.url_helpers

      def test_breadcrumb_list_schema
        product = create_product
        category = create_category(product_ids: [product.id]) # so the product will have a parent
        create_taxon(navigable: category)

        view_model = ProductViewModel.wrap(product)
        breadcrumbs = view_model.breadcrumbs.map { |t| [t.name, storefront_url_for(t)] }
        schema = breadcrumb_list_schema(breadcrumbs)
        urls = schema[:itemListElement].map { |e| e[:item][:@id] }
        product_url = storefront.product_url(product, host: Workarea.config.host)

        assert_equal('http://schema.org', schema[:@context])
        assert_equal('BreadcrumbList', schema[:@type])
        assert_equal(product_url, urls.last)
        assert_includes(urls, product_url)
      end
    end
  end
end
