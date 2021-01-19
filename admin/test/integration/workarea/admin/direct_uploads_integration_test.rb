require 'test_helper'

module Workarea
  module Admin
    class DirectUploadsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_ensures_cors_policy_for_product_images
        DirectUpload.expects(:ensure_cors!).once
        get admin.product_images_direct_uploads_path
        assert(response.ok?)
      end

      def test_getting_an_upload_url
        create_product(id: 'foo')

        get admin.new_direct_uploads_path,
          params: { type: 'product_image', filename: 'foo.0.jpg' }

        results = JSON.parse(response.body)
        assert_includes(results['upload_url'], 'foo.0.jpg')
        assert_match(URI::regexp, results['upload_url'])
      end

      def test_getting_a_missing_product_upload_error
        get admin.new_direct_uploads_path,
          params: { type: 'product_image', filename: 'foo.0.jpg' }

        results = JSON.parse(response.body)
        error = t('workarea.admin.direct_uploads.product_match_error', id: 'foo')
        assert_nil(results['upload_url'])
        assert_includes(results['error'], error)
      end

      def test_getting_a_malformed_filename_upload_error
        create_product(id: 'foo')

        get admin.new_direct_uploads_path,
          params: { type: 'product_image', filename: 'foo' }

        results = JSON.parse(response.body)
        error = t('workarea.admin.direct_uploads.formatting_error')
        assert_nil(results['upload_url'])
        assert_includes(results['error'], error)
      end

      def test_processing_a_product_image
        product = create_product(id: 'foo', images: [])

        Workarea.s3.directories.new(key: Configuration::S3.bucket).files.create(
          key: DirectUpload.new(:product_image, 'foo.0.jpg').key,
          body: product_image_file
        )

        post admin.direct_uploads_path,
          params: { type: 'product_image', filename: 'foo.0.jpg' }

        assert(response.redirect?)

        product.reload
        assert_equal(1, product.images.size)
        assert_equal('foo.0.jpg', product.images.first.image_name)
        assert_equal(0, product.images.first.position)
      end

      def test_processing_an_asset
        Workarea.s3.directories.new(key: Configuration::S3.bucket).files.create(
          key: DirectUpload.new(:asset, 'foo.pdf').key,
          body: pdf_file
        )

        post admin.direct_uploads_path,
          params: { type: 'asset', filename: 'foo.pdf' }

        assert(response.redirect?)
        assert_equal(1, Content::Asset.count)
        assert_equal('foo.pdf', Content::Asset.first.file_name)
      end

      def test_mocking_endpoint_for_development
        put admin.upload_direct_uploads_path(type: 'asset', filename: 'foo.pdf'),
          env: { 'RAW_POST_DATA' => pdf_file }

        post admin.direct_uploads_path,
          params: { type: 'asset', filename: 'foo.pdf' }

        assert_equal(1, Content::Asset.count)
        assert_equal('foo.pdf', Content::Asset.first.file_name)
      end
    end
  end
end
