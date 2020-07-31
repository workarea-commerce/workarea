module Workarea
  module Storefront
    class InquiryViewModel < ApplicationViewModel
      include DisplayContent

      def title
        browser_title.presence ||
          ::I18n.t('workarea.storefront.contacts.contact_us')
      end

      def subjects
        Workarea.config.inquiry_subjects.map do |key, default_value|
          [
            I18n.t('workarea.inquiry.subjects')[key.optionize.to_sym].presence ||
            default_value,
            key
          ]
        end
      end

      private

      def content_lookup
        'contact_us'
      end
    end
  end
end
