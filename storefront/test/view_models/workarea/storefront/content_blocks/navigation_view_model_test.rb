require 'test_helper'

module Workarea
  module Storefront
    module ContentBlocks
      class NavigationViewModelTest < Workarea::TestCase
        setup do
          @view_model = NavigationViewModel.new
        end

        def test_finding_taxons
          root = create_taxon
          first = create_taxon(parent: root)
          second = create_taxon(parent: root)

          results = @view_model.find_taxons_for(root)
          assert_equal([first, second], results)

          results = @view_model.find_taxons_for(first)
          assert_equal([first], results)

          results = @view_model.find_taxons_for(second)
          assert_equal([second], results)
        end

        def test_restricting_taxons_with_active_navigable
          root = create_taxon
          first = create_taxon(parent: root)
          second = create_taxon(
            parent: root,
            navigable: create_page(active: true)
          )
          third = create_taxon(
            parent: root,
            navigable: create_page(active: false)
          )

          results = @view_model.find_taxons_for(root)
          assert_equal([first, second], results)

          results = @view_model.find_taxons_for(first)
          assert_equal([first], results)

          results = @view_model.find_taxons_for(second)
          assert_equal([second], results)

          results = @view_model.find_taxons_for(third)
          assert_equal([], results)
        end
      end
    end
  end
end
