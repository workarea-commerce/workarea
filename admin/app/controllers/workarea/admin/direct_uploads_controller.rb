module Workarea
  module Admin
    class DirectUploadsController < Admin::ApplicationController
      def product_images
        DirectUpload.ensure_cors!(request.url) if Configuration::S3.configured?
      end

      def new
        direct_upload = DirectUpload.new(params[:type], params[:filename])

        if direct_upload.valid?
          render json: { upload_url: direct_upload.upload_url }, status: :ok
        else
          errors = direct_upload.errors.full_messages.to_sentence
          render json: { error: errors }, status: :unprocessable_entity
        end
      end

      def create
        ProcessDirectUpload.perform_async(params[:type], params[:filename])
        request.xhr? ? head(:ok) : redirect_back(fallback_location: root_path)
      end

      # This is only used when no S3 config present (like local development)
      #
      # When this is used, Fog will be in mock mode (Fog.mock!) so it simulates
      # the use of a direct-to-S3 upload.
      def upload
        upload = DirectUpload.new(params[:type], "#{params[:filename]}.#{params[:format]}")

        Workarea.s3.put_bucket(Configuration::S3.bucket) rescue nil
        Workarea.s3.put_object(Configuration::S3.bucket, upload.key, request.body)
      end
    end
  end
end
