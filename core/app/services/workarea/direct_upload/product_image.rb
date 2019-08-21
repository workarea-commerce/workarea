module Workarea
  class DirectUpload
    class ProductImage
      include Processor

      validate :product_exists
      validate :filename_format

      delegate :t, to: I18n

      def perform
        attributes = { image: direct_upload.file, image_name: direct_upload.filename }
        attributes.merge!(
          Workarea
            .config
            .direct_upload_product_image_filename_processor
            .call(direct_upload.filename)
        )

        case_insensitive = /^#{Regexp.quote(attributes[:product_id])}$/i
        product = Catalog::Product.where(id: case_insensitive).first
        product.images.create!(attributes.except(:product_id))
      end

      private

      def product_exists
        product_id = direct_upload.filename.split('.').first

        if Workarea::Catalog::Product.where(id: product_id).empty?
          errors.add(:base, t('workarea.admin.direct_uploads.product_match_error', id: product_id))
        end
      end

      def filename_format
        if Workarea.config.direct_upload_product_image_filename_regex !~ direct_upload.filename
          errors.add(:base, t('workarea.admin.direct_uploads.formatting_error'))
        end
      end
    end
  end
end
