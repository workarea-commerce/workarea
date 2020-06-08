module Workarea
  class DirectUpload
    class InvalidTypeError < RuntimeError; end

    def self.ensure_cors!(request_url)
      uri = URI.parse(request_url)
      url = "#{uri.scheme}://#{uri.host}"
      url += ":#{uri.port}" unless uri.port.in? [80, 443]
      id = "direct_upload_#{url}"

      response = begin
        Workarea.s3.get_bucket_cors(Configuration::S3.bucket)
      rescue Excon::Error::NotFound
        Excon::Response.new(body: { 'CORSConfiguration' => [] })
      end

      cors = response.data[:body]

      unless cors['CORSConfiguration'].pluck('ID').include?(id)
        cors['CORSConfiguration'] << {
          'ID' => id,
          'AllowedMethod' => 'PUT',
          'AllowedOrigin' => url,
          'AllowedHeader' => '*'
        }

        Workarea.s3.put_bucket_cors(Configuration::S3.bucket, cors)
      end
    end

    attr_reader :type, :filename

    delegate :valid?, :errors, to: :processor

    def initialize(type, filename)
      @type = type.to_s
      @filename = filename

      raise InvalidTypeError unless processor.present?
    end

    def key
      "#{type.underscore}_direct_upload/#{filename}"
    end

    def upload_url
      if Configuration::S3.configured?
        Workarea.s3.put_object_url(Configuration::S3.bucket, key, time_to_access)
      else
        Admin::Engine
          .routes
          .url_helpers
          .upload_direct_uploads_path(type: type, filename: filename)
      end
    end

    def process!
      processor.perform
      delete!
    end

    def file
      @file ||= begin
        bucket = Workarea.s3.directories.new(key: Configuration::S3.bucket)
        bucket.files.get(key)&.body
      end
    end

    def delete!
      Workarea.s3.delete_object(Configuration::S3.bucket, key)
    end

    private

    def processor
      return @processor if defined?(@processor)
      @processor = "Workarea::DirectUpload::#{@type.camelize}".constantize.new(self)
    rescue
      @processor = nil
    end

    def time_to_access
      Workarea.config.product_bulk_image_upload_access_time.from_now.to_i
    end
  end
end
