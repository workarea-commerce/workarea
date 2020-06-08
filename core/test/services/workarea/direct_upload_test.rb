require 'test_helper'

module Workarea
  class DirectUploadTest < TestCase
    def test_asserting_type
      assert_raises { DirectUpload.new(:foo, filename) }
    end

    def test_getting_upload_url
      filename = '001.2.red.jpg'
      result = DirectUpload.new(:product_image, filename).upload_url

      assert_includes(result, filename)
      assert_match(URI::regexp, result)
    end

    def test_getting_the_file
      upload_file
      direct_upload = DirectUpload.new(:product_image, 'foo.0.jpg')

      File.open(product_image_file_path, 'rb') do |file|
        assert_equal(product_image_file, direct_upload.file)
      end
    end

    def test_deleting
      upload_file
      DirectUpload.new(:product_image, 'foo.0.jpg').delete!
      assert_nil(DirectUpload.new(:product_image, 'foo.0.jpg').file)
    end

    def test_validation
      direct_upload = DirectUpload.new(:product_image, 'foo.0.jpg')
      refute(direct_upload.valid?)

      create_product(id: 'foo')
      assert(direct_upload.valid?)

      direct_upload = DirectUpload.new(:product_image, 'foo.0.bar.jpg')
      assert(direct_upload.valid?)

      direct_upload = DirectUpload.new(:product_image, 'foo.jpg')
      refute(direct_upload.valid?)

      direct_upload = DirectUpload.new(:product_image, 'bar.0.jpg')
      refute(direct_upload.valid?)
    end

    def test_ensure_cors
      response = mock('Excon::Response')
      response.expects(:data)
              .times(3)
              .returns(body: { 'CORSConfiguration' => [] })
      Workarea.s3.expects(:get_bucket_cors)
                 .times(3)
                 .with(Configuration::S3.bucket)
                 .returns(response)
      Workarea.s3.expects(:put_bucket_cors).with(
        Configuration::S3.bucket,
        'CORSConfiguration' => [
          {
            'ID' => "direct_upload_http://test.host",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'http://test.host',
            'AllowedHeader' => '*'
          }
        ]
      ).returns(true)
      Workarea.s3.expects(:put_bucket_cors).with(
        Configuration::S3.bucket,
        'CORSConfiguration' => [
          {
            'ID' => "direct_upload_http://test.host",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'http://test.host',
            'AllowedHeader' => '*'
          },
          {
            'ID' => "direct_upload_http://localhost:3000",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'http://localhost:3000',
            'AllowedHeader' => '*'
          }
        ]
      ).returns(true)
      Workarea.s3.expects(:put_bucket_cors).with(
        Configuration::S3.bucket,
        'CORSConfiguration' => [
          {
            'ID' => "direct_upload_http://test.host",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'http://test.host',
            'AllowedHeader' => '*'
          },
          {
            'ID' => "direct_upload_http://localhost:3000",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'http://localhost:3000',
            'AllowedHeader' => '*'
          },
          {
            'ID' => "direct_upload_https://example.com",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'https://example.com',
            'AllowedHeader' => '*'
          }
        ]
      ).returns(true)

      assert(DirectUpload.ensure_cors!('http://test.host/admin/content_assets'))
      assert(DirectUpload.ensure_cors!('http://localhost:3000/admin/content_assets'))
      assert(DirectUpload.ensure_cors!('https://example.com/admin/direct_uploads'))
    end

    def test_ensure_cors_with_no_existing_configuration
      Workarea.s3.expects(:get_bucket_cors)
                 .raises(Excon::Errors::NotFound.new('CORS configuration does not exist'))


      Workarea.s3.expects(:put_bucket_cors).with(
        Configuration::S3.bucket,
        'CORSConfiguration' => [
          {
            'ID' => "direct_upload_http://test.host",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'http://test.host',
            'AllowedHeader' => '*'
          }
        ]
      ).returns(true)

      assert(DirectUpload.ensure_cors!('http://test.host/admin/content_assets'))
    end

    private

    def upload_file
      Workarea.s3.directories.new(key: Configuration::S3.bucket).files.create(
        key: DirectUpload.new(:product_image, 'foo.0.jpg').key,
        body: product_image_file
      )
    end
  end
end
