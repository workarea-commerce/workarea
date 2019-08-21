module Mongoid
  module AuditLog
    decorate Entry, with: :workarea do
      decorated do
        field :release_id, type: String
        before_save :set_release_id

        index({ action: 1, created_at: 1 })
        index({ action: 1, audited_type: 1, created_at: 1 })
        index({ audited_id: 1, audited_type: 1, release_id: 1 })
        index({ audited_type: 1 })
        index({ 'document_path.id' => 1 })
        index(
          { created_at: 1 },
          { expire_after_seconds: 3.months.seconds.to_i }
        )
      end

      def model_name
        model_attributes['name'][I18n.locale.to_s].presence ||
          model_attributes['name']
      end

      def release
        @release ||= try_scheduled_for_release_change ||
                      try_performed_by_release_change
      end

      def publish?
        tracked_changes.keys == %w(published_at publish_at) ||
          tracked_changes.keys == %w(published_at)
      end

      def restorable?
        super && !orphaned?
      end

      private

      def try_scheduled_for_release_change
        return nil if release_id.blank?
        Workarea::Release.find(release_id) rescue nil
      end

      # HACK to try to match a release for publishing display
      def try_performed_by_release_change
        return unless modifier.try(:system?)
        Workarea::Release.find_by(name: modifier.first_name) rescue nil
      end

      def set_release_id
        if audited_type.present? && audited_type.constantize < Workarea::Releasable
          self.release_id = Workarea::Release.current.try(:id)
        end
      end

      def orphaned?
        return false unless audited_type.constantize.include?(Mongoid::Tree)

        parent = audited_type.constantize.find(model_attributes['parent_id']) rescue nil

        parent.blank?
      end
    end
  end
end
