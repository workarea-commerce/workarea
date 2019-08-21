require 'test_helper'

module Workarea
  module Storefront
    class PagesIntegrationTest < Workarea::IntegrationTest
      def test_does_not_show_an_inactive_page
        assert_raise InvalidDisplay do
          get storefront.page_path(create_page(active: false))
          assert(response.not_found?)
        end
      end

      def test_allows_showing_an_inactive_product_when_admin_user
        set_current_user(create_user(admin: true))

        get storefront.page_path(create_page(active: false))
        assert(response.ok?)
      end

      def test_open_graph_image_url
        page = create_page

        get storefront.page_path(page)

        placeholder = Workarea.config.open_graph_placeholder_image_name
        assert_match(/#{File.basename(placeholder)}.*og:image/, response.body)

        asset = create_asset
        content = Content.for(page)
        content.update_attributes!(open_graph_asset_id: asset.id)

        get storefront.page_path(page)

        assert_match(/#{asset.file_name}.*og:image/, response.body)
      end

      def test_rendering_web_manifest
        get storefront.web_manifest_path

        assert_match('favicons/192x192', response.body)
        assert_match('favicons/512x512', response.body)
        assert_match('theme_color', response.body)
        assert_match('background_color', response.body)
        assert_match('display', response.body)
      end

      def test_rendering_browser_config
        get storefront.browser_config_path

        assert_match('favicons/150x150', response.body)
        assert_match('square150x150logo', response.body)
        assert_match('<TileColor>', response.body)
      end
    end
  end
end
