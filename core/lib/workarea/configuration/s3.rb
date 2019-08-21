module Workarea
  module Configuration
    class S3
      class << self
        def internal
          @dragonfly ||= new(:s3)
        end

        def integration
          @integration ||= new(:s3_integration)
        end

        delegate_missing_to :internal
      end

      def initialize(slug)
        @slug = slug
        @config = config.presence || secrets.presence || credentials.presence || {}
      end

      def region
        ENV["#{prefix}_REGION"].presence || @config[:region].presence || 'us-east-1'
      end

      def bucket
        configured_bucket.presence || 'test'
      end

      def access_key_id
        ENV["#{prefix}_ACCESS_KEY_ID"].presence || @config[:access_key_id]
      end

      def secret_access_key
        ENV["#{prefix}_SECRET_ACCESS_KEY"].presence || @config[:secret_access_key]
      end

      def use_iam_profile?
        access_key_id.blank? && secret_access_key.blank?
      end

      def configured?
        configured_bucket.present?
      end

      private

      def prefix
        @prefix ||= "WORKAREA_#{@slug.to_s.underscore.upcase}"
      end

      def config
        Workarea.config.send(@slug).to_h.with_indifferent_access
      end

      def secrets
        Rails.application.secrets.send(@slug).to_h.with_indifferent_access
      end

      def credentials
        Rails.application.credentials.send(@slug).to_h.with_indifferent_access
      end

      def configured_bucket
        ENV["#{prefix}_BUCKET_NAME"].presence || @config[:bucket_name]
      end
    end
  end
end
