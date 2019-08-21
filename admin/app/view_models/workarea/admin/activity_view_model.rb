module Workarea
  module Admin
    class ActivityViewModel < ApplicationViewModel
      def entries
        @entries ||= scoped_entries.page(page).per(per_page)
      end

      def type_options
        [[t('workarea.admin.activities.filters.all_types'), nil]] +
          types.map do |type|
            name = ActiveModel::Naming.param_key(type.constantize)
            [name.titleize.downcase, type]
          end
      end

      def admin_options
        [[t('workarea.admin.activities.filters.everyone'), nil]] +
          User.admins.map { |u| [u.name, u.id] }
      end

      def days
        @days ||= entries.reduce({}) do |memo, entry|
          day = entry.created_at.to_date
          memo[day] ||= []
          memo[day] << entry
          memo
        end
      end

      def page
        (options[:page].presence || 1).to_i
      end

      def hide_first_header?
        return false if page == 1

        previous_entry = scoped_entries.skip(entries.offset_value - 1).first
        previous_entry.created_at.to_date == entries.first.created_at.to_date
      end

      private

      def scoped_entries
        criteria = Mongoid::AuditLog::Entry
                    .desc(:created_at)
                    .where(:modifier_id.exists => true)
                    .where(
                      :audited_type.nin =>
                        Workarea.config.activity_excluded_types.to_a
                    )

        if admin_ids.present?
          criteria = criteria.any_in(modifier_id: admin_ids)
        end

        if type_filters.present?
          criteria = criteria.any_in(audited_type: type_filters)
        end

        if options[:id].present?
          Array(options[:id]).each do |id|
            criteria = criteria.any_of(
              { audited_id: id },
              { 'document_path.id' => convert_to_object_id(id) }
            )
          end
        end

        if options[:created_at_greater_than].present?
          criteria = criteria.where(
            :created_at.gt => options[:created_at_greater_than]
          )
        end

        if options[:created_at_less_than].present?
          criteria = criteria.where(
            :created_at.lt => options[:created_at_less_than]
          )
        end

        criteria
      end

      def types
        Mongoid::AuditLog::Entry.distinct(:audited_type)
      end

      def admin_ids
        Array(options[:admin]).map(&:to_s).reject(&:blank?)
      end

      def type_filters
        Array(options[:type]).map(&:to_s).reject(&:blank?)
      end

      def convert_to_object_id(id)
        BSON::ObjectId.from_string(id.to_s)
      rescue BSON::ObjectId::Invalid
        id
      end

      def per_page
        options[:per_page] || Workarea.config.per_page
      end
    end
  end
end
