require 'test_helper'

module Workarea
  module Navigation
    class TaxonTest < TestCase
      def test_cannot_link_to_the_same_navigable_more_than_once_in_a_tree
        navigable = create_page(name: 'Test Taxon', slug: 'foo')

        create_taxon(name: 'test', navigable: navigable)
        taxon = Taxon.new(name: 'test', navigable: navigable)

        refute(taxon.valid?)
      end

      def test_prefers_the_passed_name
        taxon = Taxon.new(name: 'Foo', navigable: create_page).tap(&:valid?)
        assert_equal('Foo', taxon.name)
      end

      def test_sets_name_and_slug_from_navigable_if_not_provided
        navigable = create_page(name: 'Test Taxon', slug: 'test-link')
        taxon = Taxon.new(navigable: navigable).tap(&:valid?)
        assert_equal('Test Taxon', taxon.name)
        assert_equal('test-link', taxon.navigable_slug)
      end

      def test_removes_navigable_references_when_setting_to_a_url
        navigable = create_page(slug: 'test')
        taxon = create_taxon(navigable: navigable)

        taxon.update_attributes(url: 'http://example.com')
        assert(taxon.navigable.blank?)
        assert(taxon.navigable_slug.blank?)
      end

      def test_destroys_children_when_destroyed
        taxon = create_taxon(navigable: create_page(slug: 'test-navigable'))
        create_taxon(parent: taxon) # child

        taxon.destroy
        assert_equal(1, Taxon.count) # root should still exist
      end

      def test_is_placeholder_if_no_navigable_and_no_url
        taxon = Taxon.new
        assert(taxon.placeholder?)

        taxon.url = 'http://google.com'
        refute(taxon.placeholder?)

        taxon.navigable = Content::Page.new
        refute(taxon.placeholder?)
      end

      def test_move_to_position
        taxon_a = create_taxon
        taxon_b = create_taxon
        taxon_c = create_taxon
        taxons = [taxon_a, taxon_b, taxon_c]

        taxon_b.move_to_position(0)
        taxons.each(&:reload)

        assert_equal(0, taxon_b.position)
        assert_equal(1, taxon_a.position)
        assert_equal(2, taxon_c.position)

        taxon_c.move_to_position(1)
        taxons.each(&:reload)

        assert_equal(0, taxon_b.position)
        assert_equal(1, taxon_c.position)
        assert_equal(2, taxon_a.position)

        taxon_b.move_to_position(3)
        taxons.each(&:reload)

        assert_equal(0, taxon_c.position)
        assert_equal(1, taxon_a.position)
        assert_equal(2, taxon_b.position)
      end

      def test_cannot_destroy_if_primary_nav
        taxon = create_taxon
        menu = create_menu(taxon: taxon)

        refute(taxon.destroy)

        menu.destroy
        assert(taxon.destroy)
      end

      def test_active
        assert(Taxon.new.active?)
        assert(Taxon.new(navigable: create_user).active?)
        assert(Taxon.new(navigable: create_page(active: true)).active?)
        refute(Taxon.new(navigable: create_page(active: false)).active?)
      end

      def test_unique_navigable_ids
        navigable = create_page
        taxon_1 = create_taxon
        taxon_2 = create_taxon
        taxon_3 = create_taxon(navigable_id: nil)
        taxon_4 = create_taxon(navigable_id: nil)
        taxon_5 = create_taxon(navigable: navigable)
        taxon_6 = Taxon.new(navigable: navigable)

        assert_nil(taxon_1.navigable_id)
        assert_nil(taxon_2.navigable_id)
        assert_nil(taxon_3.navigable_id)
        assert_nil(taxon_4.navigable_id)
        assert_equal(navigable.id, taxon_5.navigable_id)
        refute(taxon_6.valid?)
      end

      def test_show_in_sitemap?
        new_taxon = Taxon.new
        nav_taxon = create_taxon(navigable: create_page)
        url_taxon = create_taxon(url: 'http://example.com')
        eml_taxon = create_taxon(url: 'mailto:noreply@example.com')
        tel_taxon = create_taxon(url: 'tel:+16108675309')
        rel_taxon = create_taxon(url: '/foo')

        assert(new_taxon.placeholder?)
        refute(new_taxon.show_in_sitemap?)
        assert(nav_taxon.show_in_sitemap?)
        assert(url_taxon.show_in_sitemap?)
        assert(rel_taxon.show_in_sitemap?)
        refute(eml_taxon.show_in_sitemap?)
        refute(tel_taxon.show_in_sitemap?)
      end
    end
  end
end
