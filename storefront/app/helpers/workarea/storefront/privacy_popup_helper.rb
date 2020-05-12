module Workarea
  module Storefront
    module PrivacyPopupHelper
      def privacy_popup?
        Workarea.config.show_privacy_popup &&
          layout_content.content_blocks_for('privacy_popup').any?
      end
    end
  end
end
