module Workarea
  module Pricing
    module UnsupportedSegmentation
      extend ActiveSupport::Concern

      included do
        validate :unsupported_segmentation
      end

      private

      def unsupported_segmentation
        if active_segment_ids.present?
          errors.add(
            :active_segment_ids,
            I18n.t('workarea.errors.messages.unsupported_segmentation')
          )
        end
      end
    end
  end
end
