require 'test_helper'

module Workarea
  module Admin
    class CreateContentPagesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_create
        post admin.create_content_pages_path,
          params: {
            page: {
              name: 'Test Page',
              tag_list: 'foo,bar,baz',
              show_navigation: true
            }
          }

        assert_equal(1, Content::Page.count)
        page = Content::Page.first

        assert_equal('Test Page', page.name)
        assert_equal(%w(foo bar baz), page.tags)
        assert(page.show_navigation?)
      end

      def test_save_taxonomy
        parent = create_taxon(name: 'Foo')
        page = create_page(name: 'Test Page')

        post admin.save_taxonomy_create_content_page_path(page),
          params: { parent_id: parent.id }

        page.reload

        assert_equal(parent.id, page.taxon.parent_id)
        assert_equal('foo-test-page', page.slug)
      end

      def test_save_navigation
        page = create_page
        taxon = create_taxon(navigable: page)

        assert_difference 'Navigation::Menu.count', 1 do
          post admin.save_navigation_create_content_page_path(page),
            params: { create_menu: true }
        end

        result = Navigation::Menu.desc(:created_at).first
        assert_equal(taxon, result.taxon)
      end

      def test_publish
        page = create_page
        create_release(name: 'Foo Release', publish_at: 1.week.from_now)
        get admin.publish_create_content_page_path(page)

        assert(response.ok?)
        assert_includes(response.body, 'Foo Release')
      end

      def test_save_publish
        page = create_page(active: false)

        post admin.save_publish_create_content_page_path(page),
          params: { activate: 'now' }

        assert(page.reload.active?)

        page.update_attributes!(active: false)

        post admin.save_publish_create_content_page_path(page),
          params: { activate: 'new_release', release: { name: '' } }

        assert(Release.empty?)
        assert(response.ok?)
        refute(response.redirect?)
        refute(page.reload.active?)

        post admin.save_publish_create_content_page_path(page),
          params: { activate: 'new_release', release: { name: 'Foo' } }

        refute(page.reload.active?)
        assert_equal(1, Release.count)
        release = Release.first
        assert_equal('Foo', release.name)
        release.as_current { assert(page.reload.active?) }

        release = create_release
        page.update_attributes!(active: false)

        post admin.save_publish_create_content_page_path(page),
          params: { activate: release.id }

        refute(page.reload.active?)
        release.as_current { assert(page.reload.active?) }
      end
    end
  end
end
