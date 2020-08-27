require 'test_helper'

module Workarea
  module Admin
    class AssetsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_ensures_cors_policy_for_bulk_upload
        Workarea.s3.expects(:get_bucket_cors).returns(mock_s3_cors_response).once
        Workarea.s3.expects(:put_bucket_cors).once
        get admin.content_assets_path
        assert(response.ok?)

        get admin.content_assets_path, xhr: true
        assert(response.ok?)

        get admin.content_assets_path
        assert(response.ok?)
      end

      def test_can_create_an_asset
        post admin.content_assets_path,
          params: {
            asset: {
              name: 'Test Asset',
              file: product_image_file_path,
              tag_list: 'foo,bar,baz'
            }
          }

        assert_equal(1, Content::Asset.count)

        asset = Content::Asset.first
        assert_equal('Test Asset', asset.name)
        assert_equal(%w(foo bar baz), asset.tags)
      end

      def test_can_update_an_asset
        asset = create_asset(
          name: 'Test Asset',
          file: product_image_file_path,
          tag_list: 'foo,bar,baz'
        )

        patch admin.content_asset_path(asset),
          params: {
            asset: {
              name: 'New Name',
              tag_list: 'other,tags'
            }
          }

        asset.reload
        assert_equal('New Name', asset.name)
        assert_equal(%w(other tags), asset.tags)
      end

      def test_can_destroy_an_asset
        asset = create_asset(file: product_image_file_path)
        delete admin.content_asset_path(asset)
        assert(Content::Asset.empty?)
      end
    end
  end
end
