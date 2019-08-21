module Workarea
  module Configuration
    module Dragonfly
      extend self

      def load
        type, options = *Workarea.config.asset_store
        options = (options || {}).with_indifferent_access

        if type == :s3 && S3.bucket.present?
          options.reverse_merge!(s3_defaults)
        elsif %i(file file_system).include?(type)
          type = :file
          options.reverse_merge!(file_system_defaults)
        end

        ::Dragonfly.app(:workarea).configure do
          # Ensure Dragonfly always uses the CDN no matter what
          url_host Rails.application.config.action_controller.asset_host
          datastore type, options
        end
      end

      def s3_defaults
        {
          region: S3.region,
          bucket_name: S3.bucket,
          access_key_id: S3.access_key_id,
          secret_access_key: S3.secret_access_key,
          use_iam_profile: S3.access_key_id.blank?,
          storage_headers: { 'x-amz-acl' => 'private' }
        }
      end

      def file_system_defaults
        {
          root_path: Rails.root.join('public/system/workarea', Rails.env).to_s,
          server_root: Rails.root.join('public').to_s
        }
      end
    end
  end
end
