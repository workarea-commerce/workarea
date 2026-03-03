# frozen_string_literal: true

# A lightweight replacement for the subset of Dragonfly Workarea relies on.
#
# Goals (prototype):
# - Store originals on S3 or filesystem using the existing Workarea.asset_store config
# - Provide stable keys compatible with the existing *_uid fields
# - Offer a simple URL + download interface for serving from Rails
#
# Non-goals (prototype):
# - full Dragonfly job DSL
# - full processor compatibility
# - background variant generation

require 'securerandom'
require 'fileutils'
require 'aws-sdk-s3'

module Workarea
  module Media
    class Storage
      def self.build
        type, options = *Workarea.config.asset_store
        options = (options || {}).with_indifferent_access

        case type
        when :s3
          S3.new(options)
        when :file, :file_system
          FileSystem.new(options)
        else
          # Default to filesystem in development/test.
          FileSystem.new(options)
        end
      end

      def generate_uid(filename)
        ext = File.extname(filename.to_s)
        date = Time.now.utc.strftime('%Y/%m/%d')
        token = SecureRandom.hex(10)
        "#{date}/#{token}#{ext}"
      end
    end

    class FileSystem < Storage
      def initialize(options)
        @root_path = options[:root_path].presence || Rails.root.join('public/system/workarea', Rails.env).to_s
      end

      def put(uid, io)
        path = path_for(uid)
        FileUtils.mkdir_p(File.dirname(path))

        io = File.open(io, 'rb') if io.is_a?(String) || io.is_a?(Pathname)
        File.open(path, 'wb') { |f| IO.copy_stream(io, f) }
      ensure
        io.close if io.respond_to?(:close) && !(io.is_a?(String) || io.is_a?(Pathname))
      end

      def open(uid)
        File.open(path_for(uid), 'rb')
      end

      def exist?(uid)
        File.exist?(path_for(uid))
      end

      def path_for(uid)
        File.join(@root_path, uid)
      end
    end

    class S3 < Storage
      def initialize(options)
        @options = options
        # dragonfly config lives in Workarea::Configuration::Dragonfly.s3_defaults
        @region = options[:region] || Workarea::Configuration::S3.region
        @bucket = options[:bucket_name] || Workarea::Configuration::S3.bucket
        @access_key_id = options[:access_key_id] || Workarea::Configuration::S3.access_key_id
        @secret_access_key = options[:secret_access_key] || Workarea::Configuration::S3.secret_access_key
      end

      def client
        @client ||= begin
          creds = if @access_key_id.present? && @secret_access_key.present?
            Aws::Credentials.new(@access_key_id, @secret_access_key)
          end

          Aws::S3::Client.new(region: @region, credentials: creds)
        end
      end

      def put(uid, io)
        io = File.open(io, 'rb') if io.is_a?(String) || io.is_a?(Pathname)
        client.put_object(
          bucket: @bucket,
          key: uid,
          body: io,
          acl: 'private'
        )
      ensure
        io.close if io.respond_to?(:close) && !(io.is_a?(String) || io.is_a?(Pathname))
      end

      def open(uid)
        resp = client.get_object(bucket: @bucket, key: uid)
        resp.body # responds to #read
      end

      def exist?(uid)
        client.head_object(bucket: @bucket, key: uid)
        true
      rescue Aws::S3::Errors::NotFound
        false
      end
    end
  end
end
