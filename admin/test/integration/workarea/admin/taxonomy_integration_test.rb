require 'test_helper'

module Workarea
  module Admin
    class TaxonomyIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup do
        @page = create_page
      end

      def test_creation
        post admin.navigation_taxons_path,
          params: {
            navigable_type: 'page',
            navigable_id: @page.id,
            taxon: { name: 'Test Taxon' }
          }

        assert_equal(2, Navigation::Taxon.count) # including root

        taxon = Navigation::Taxon.desc(:created_at).first

        assert_equal(Navigation::Taxon.root, taxon.root)
        assert_equal(@page, taxon.navigable)
        assert_equal('Test Taxon', taxon.name)
      end

      def test_updates
        taxon = create_taxon

        patch admin.navigation_taxon_path(taxon),
          params: {
            taxon: { name: 'Renamed Taxon' },
            navigable_type: 'page',
            navigable_id: @page.id
          }

        taxon.reload
        assert_equal('Renamed Taxon', taxon.name)
        assert_equal(@page, taxon.navigable)
      end

      def test_deletion
        taxon = create_taxon
        delete admin.navigation_taxon_path(taxon)
        assert_equal(1, Navigation::Taxon.count)
      end

      def test_moving
        first  = create_taxon
        second = create_taxon(parent: first)

        patch admin.move_navigation_taxon_path(second),
          params: { direction: 'above', other_id: first.id }

        first.reload
        second.reload

        assert(second.at_top?)
        assert(first.at_bottom?)
        refute(first.has_children?)

        patch admin.move_navigation_taxon_path(second),
          params: { direction: 'below', other_id: first.id }

        first.reload
        second.reload

        assert(second.at_bottom?)
        assert(first.at_top?)

        patch admin.move_navigation_taxon_path(second),
          params: { other_id: first.id }

        first.reload
        second.reload

        assert_equal(first.id, second.parent_id)
      end

      def test_showing_current_taxon_by_url
        category = create_category
        taxon = create_taxon(
          navigable_type: 'Workarea::Catalog::Category',
          navigable_id: category.id
        )

        get admin.edit_navigation_taxon_path(taxon)
        assert(response.body.include?(category.name))
      end
    end
  end
end
