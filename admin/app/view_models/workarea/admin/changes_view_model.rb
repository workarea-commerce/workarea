module Workarea
  module Admin
    class ChangesViewModel < ApplicationViewModel
      def id
        Digest::SHA1.hexdigest(model.to_s)
      end

      def present_changes
        model.reject { |k, v| k.blank? || v.all?(&:blank?) }
      end

      def relevant_fields
        present_changes
          .keys
          .map { |k| remove_id_from_field_name(k) }
          .map(&:humanize)
          .map(&:downcase)
          .map { |n| t("workarea.admin.fields.#{n}", default: n) }
      end

      def to_html
        if model.blank? || relevant_fields.blank?
          t('workarea.admin.fields', count: 0).html_safe
        elsif relevant_fields.size > 3
          %Q(
              <a href="#changes-#{id}" data-tooltip="true">
                #{t('workarea.admin.fields', count: relevant_fields.size)}
              </a>
              <div id="changes-#{id}" class="tooltip-content">
                <p>#{relevant_fields.to_sentence}</p>
              </div>
          ).html_safe
        else
          relevant_fields
            .map { |f| "<strong>#{f}</strong>" }
            .to_sentence
            .html_safe
        end
      end

      private

      def remove_id_from_field_name(field)
        if field.ends_with?('_ids')
          field.gsub(/_ids$/, '').pluralize
        else
          field.gsub(/_u?id$/, '')
        end
      end
    end
  end
end
