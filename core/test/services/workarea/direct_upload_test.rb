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
      original_host = Workarea.config.host
      Workarea.config.host = 'test.host'
      dev_request = mock(
        'ActionDispatch::Request',
        ssl?: false,
        host: 'localhost',
        port: 3000
      )
      prod_request = mock(
        'ActionDispatch::Request',
        ssl?: true,
        host: 'example.com',
        port: 443
      )

      Workarea.s3.expects(:put_bucket_cors).with(
        Configuration::S3.bucket,
        'CORSConfiguration' => [
          {
            'ID' => "direct_upload_test.host",
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
            'ID' => "direct_upload_localhost",
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
            'ID' => "direct_upload_example.com",
            'AllowedMethod' => 'PUT',
            'AllowedOrigin' => 'https://example.com',
            'AllowedHeader' => '*'
          }
        ]
      ).returns(true)


      assert(DirectUpload.ensure_cors!)
      assert(DirectUpload.ensure_cors!(dev_request))
      assert(DirectUpload.ensure_cors!(prod_request))
    ensure
      Workarea.config.host = original_host
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
