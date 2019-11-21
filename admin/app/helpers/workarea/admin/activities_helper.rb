module Workarea
  module Admin
    module ActivitiesHelper
      def render_activity_entry(entry)
        model_key = ActiveModel::Naming.param_key(entry.audited_type.constantize)
        partial_name = "#{model_key}_#{entry.action}"
        render "workarea/admin/activities/#{partial_name}", entry: entry
      rescue ActionView::MissingTemplate
        render "workarea/admin/activities/#{entry.action}", entry: entry
      end

      def render_activity_category_value(attributes)
        name = attributes['name'][I18n.locale.to_s]
        ids = attributes['value'][I18n.locale.to_s].split(',').reject(&:blank?)
        return ids unless name == 'category'

        Catalog::Category.where(:id.in => ids).map(&:name).to_sentence
      end

      def link_to_modifier(entry, &block)
        content = if block_given?
                    capture(&block)
                  elsif entry.modifier.present?
                    entry.modifier.name
                  elsif entry.modifier_id.present?
                    t('workarea.admin.activities.modifiers.no_longer_exists')
                  elsif entry.try(:release).present?
                    entry.release.name
                  else
                    t('workarea.admin.activities.modifiers.unknown')
                  end

        if entry.modifier.present? && !entry.modifier.system?
          if entry.modifier.persisted?
            link_to content, user_path(entry.modifier)
          else
            content_tag(:span, content)
          end
        elsif entry.try(:release).present?
          link_to content, release_path(entry.release)
        else
          content
        end
      end

      def fields_clause_for(changes)
        ChangesViewModel.new(changes).to_html
      end

      def activity_time(value)
        if value.to_date == Time.zone.today
          local_time_ago(value)
        else
          local_time(value, :time_only)
        end
      end

      def activity_model_name(entry)
        entry.audited_type.gsub(/Workarea::/, '').gsub(/::/, ' ').titleize
      end

      def link_to_restore_for(entry)
        if entry.restorable? && current_user.can_restore?
          link_to(
            t('workarea.admin.activities.restore'),
            restore_trash_path(entry),
            data: { method: 'post' }
          )
        end
      end
    end
  end
end
