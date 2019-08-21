require 'test_helper'

module Workarea
  module Search
    class Admin
      class CatalogCategoryTest < TestCase
        include SearchIndexing

        def test_facets
          product = create_product
          has_products = create_category(product_ids: [product.id])
          empty = create_category

          facets = CatalogCategory.new(has_products).facets
          refute_includes(
            facets[:issues],
            t('workarea.alerts.issues.no_displayable_products')
          )

          facets = CatalogCategory.new(empty).facets
          assert_includes(
            facets[:issues],
            t('workarea.alerts.issues.no_displayable_products')
          )

          category = create_category
          facets = CatalogCategory.new(category).facets
          assert_includes(
            facets[:issues],
            t('workarea.alerts.issues.not_in_taxonomy')
          )

          create_taxon(navigable: category)

          facets = CatalogCategory.new(category).facets
          refute_includes(
            facets[:issues],
            t('workarea.alerts.issues.not_in_taxonomy')
          )
        end
      end
    end
  end
end
