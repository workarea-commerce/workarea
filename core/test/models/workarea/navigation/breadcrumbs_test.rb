require 'test_helper'

module Workarea
  module Navigation
    class BreadcrumbsTest < Workarea::TestCase
      setup do
        @navigable = Content::Page.new(name: 'Test Taxon', slug: 'test-link')
        @first = create_taxon(name: 'First')
        @second = create_taxon(name: 'Second', parent: @first, navigable: @navigable)
      end

      def test_global_id
        navigable = create_page
        via = Breadcrumbs.new(navigable).to_global_id

        result = Breadcrumbs.from_global_id(via)
        assert_equal(navigable, result.navigable)
      end

      def test_collection
        breadcrumbs = Breadcrumbs.new(@navigable)
        assert_equal(3, breadcrumbs.length) # including home
      end

      def test_last
        model = create_product
        breadcrumbs = Breadcrumbs.new(@navigable, last: model)

        assert(breadcrumbs.last.is_a?(Navigation::Taxon))
        assert_equal(4, breadcrumbs.length) # including home
        assert_equal(model, breadcrumbs.last.navigable)
        assert_equal(model.name, breadcrumbs.last.name)

        model = create_inventory
        breadcrumbs = Breadcrumbs.new(@navigable, last: model.id)

        assert(breadcrumbs.last.is_a?(Navigation::Taxon))
        assert_equal(4, breadcrumbs.length) # including home
        assert_equal(model.id, breadcrumbs.last.name)
      end

      def test_selected
        breadcrumbs = Breadcrumbs.new(@navigable)

        refute(breadcrumbs.selected?(create_taxon))
        assert(breadcrumbs.selected?(@second))
        assert(breadcrumbs.selected?(@first))
      end

      def test_join
        breadcrumbs = Breadcrumbs.new(@navigable)
        assert_equal('Home > First > Second', breadcrumbs.join(' > '))
      end

      def test_presence
        assert(Breadcrumbs.new(nil).blank?)
        assert(Breadcrumbs.new(create_page).blank?)
        assert(Breadcrumbs.new(@navigable).present?)
      end
    end
  end
end
