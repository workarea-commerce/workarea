require 'test_helper'

module Workarea
  class SetNavigableTest < TestCase
    def taxon
      @taxon ||= Navigation::Taxon.new
    end

    def test_navigable_class
      service = SetNavigable.new(
        taxon,
        navigable_type: 'category',
        navigable_id: '1234',
        new_navigable_type: 'page',
        new_navigable_name: ''
      )

      assert_equal(Catalog::Category, service.navigable_class)

      service = SetNavigable.new(
        taxon,
        navigable_type: 'page',
        navigable_id: '',
        new_navigable_type: 'page',
        new_navigable_name: 'Test Page'
      )

      assert_equal(Content::Page, service.navigable_class)

      service = SetNavigable.new(
        taxon,
        navigable_type: 'product',
        navigable_id: '',
        new_navigable_type: 'product',
        new_navigable_name: 'Test Product'
      )

      assert_equal(Catalog::Product, service.navigable_class)
    end

    def test_remove_navigable
      page = create_page
      taxon = create_taxon(navigable: page)
      service = SetNavigable.new(taxon, navigable_type: 'page', navigable_id: '')

      assert_equal(page, taxon.navigable)
      assert_nil(service.navigable)

      service.set

      assert_nil(taxon.navigable)
    end
  end
end
