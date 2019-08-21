require 'test_helper'

module Workarea
  module Admin
    class CreateCatalogCategoriesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        post admin.create_catalog_categories_path,
          params: {
            category: {
              name: 'Test Category',
              tag_list: 'foo,bar,baz',
              show_navigation: true
            }
          }

        assert_equal(1, Catalog::Category.count)
        category = Catalog::Category.first

        assert_equal('Test Category', category.name)
        assert_equal(%w(foo bar baz), category.tags)
        assert(category.show_navigation?)
      end

      def test_save_taxonomy
        parent = create_taxon(name: 'Foo')
        category = create_category(name: 'Test Category')

        post admin.save_taxonomy_create_catalog_category_path(category),
          params: { parent_id: parent.id }

        category.reload

        assert_equal(parent.id, category.taxon.parent_id)
        assert_equal('foo-test-category', category.slug)
      end

      def test_save_navigation
        category = create_category
        taxon = create_taxon(navigable: category)

        assert_difference 'Navigation::Menu.count', 1 do
          post admin.save_navigation_create_catalog_category_path(category),
            params: { create_menu: true }
        end

        result = Navigation::Menu.desc(:created_at).first
        assert_equal(taxon, result.taxon)
      end

      def test_publish
        category = create_category
        create_release(name: 'Foo Release', publish_at: 1.week.from_now)
        get admin.publish_create_catalog_category_path(category)

        assert(response.ok?)
        assert_includes(response.body, 'Foo Release')
      end

      def test_save_publish
        category = create_category(active: false)

        post admin.save_publish_create_catalog_category_path(category),
          params: { activate: 'now' }

        assert(category.reload.active?)

        category.update_attributes!(active: false)

        post admin.save_publish_create_catalog_category_path(category),
          params: { activate: 'new_release', release: { name: '' } }

        assert(Release.empty?)
        assert(response.ok?)
        refute(response.redirect?)
        refute(category.reload.active?)

        post admin.save_publish_create_catalog_category_path(category),
          params: { activate: 'new_release', release: { name: 'Foo' } }

        refute(category.reload.active?)
        assert_equal(1, Release.count)
        release = Release.first
        assert_equal('Foo', release.name)
        release.as_current { assert(category.reload.active?) }

        release = create_release
        category.update_attributes!(active: false)

        post admin.save_publish_create_catalog_category_path(category),
          params: { activate: release.id }

        refute(category.reload.active?)
        release.as_current { assert(category.reload.active?) }
      end
    end
  end
end
