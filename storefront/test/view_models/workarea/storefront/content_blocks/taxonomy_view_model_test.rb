require 'test_helper'

module Workarea
  module Storefront
    module ContentBlocks
      class TaxonomyViewModelTest < Workarea::TestCase
        def test_taxons
          taxon = create_taxon
          create_taxon(name: 'Child 1', parent: taxon)
          create_taxon(name: 'Child 2', parent: taxon)
          create_taxon(name: 'Child 3', parent: taxon)

          block = Content::Block.new(
            type_id: 'taxonomy',
            data: { 'start' => taxon.id.to_s }
          )
          assert_equal(3, TaxonomyViewModel.new(block).taxons.size)

          taxon.destroy
          assert_equal([], TaxonomyViewModel.new(block).taxons)
        end

        def test_starting_taxon
          taxon = create_taxon

          block = Content::Block.new(
            type_id: 'taxonomy',
            data: { 'start' => taxon.id.to_s }
          )
          assert_equal(taxon, TaxonomyViewModel.new(block).starting_taxon)

          taxon.destroy
          assert_nil(TaxonomyViewModel.new(block).starting_taxon)
        end

        def test_show_starting_taxon
          taxon = create_taxon

          block = Content::Block.new(
            type_id: 'taxonomy',
            data: { 'start' => taxon.id.to_s, show_starting_taxon: true }
          )

          assert(TaxonomyViewModel.new(block).show_starting_taxon?)
        end

        def test_show_starting_taxon_false_if_starting_taxon_is_nil
          taxon = create_taxon

          block = Content::Block.new(
            type_id: 'taxonomy',
            data: { 'start' => taxon.id.to_s, show_starting_taxon: true }
          )
          taxon.delete

          refute(TaxonomyViewModel.new(block).show_starting_taxon?)
        end

        def test_starting_taxon_and_start_has_no_children
          taxon = create_taxon

          block = Content::Block.new(
            type_id: 'taxonomy',
            data: { 'start' => taxon.id.to_s, show_starting_taxon: true }
          )
          assert(TaxonomyViewModel.new(block).taxons.empty?)

          child = create_taxon(name: 'Child 1', parent: taxon)
          refute(TaxonomyViewModel.new(block).taxons.empty?)
          child.destroy

          block = Content::Block.new(
            type_id: 'taxonomy',
            data: { 'start' => taxon.id.to_s, show_starting_taxon: false }
          )
          refute(TaxonomyViewModel.new(block).taxons.empty?)
        end
      end
    end
  end
end
