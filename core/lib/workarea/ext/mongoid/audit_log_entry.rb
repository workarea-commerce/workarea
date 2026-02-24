module Mongoid
  module AuditLog
    decorate Entry, with: :workarea do
      decorated do
        # WA-NEW-010: Re-declare :action as String instead of Symbol.
        # mongoid-audit_log defines `field :action, type: Symbol`, which
        # triggers "The BSON symbol type is deprecated; use String instead"
        # from Mongoid's field validator on every test boot.  Storing the
        # action as a plain String avoids the BSON Symbol wire type entirely.
        # The #action reader (below) returns a Symbol so all callers that
        # compare against symbol literals (e.g. `action == :create`) continue
        # to work without change.
        field :action, type: String, overwrite: true

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

      # WA-NEW-010: Return the action as a Symbol so callers like
      # `action == :create` and the gem's own `create?`/`update?`/`destroy?`
      # predicates continue to work after the field type changed to String.
      def action
        super&.to_sym
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
