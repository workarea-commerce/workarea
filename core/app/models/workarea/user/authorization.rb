module Workarea
  class User
    module Authorization
      extend ActiveSupport::Concern
      include UrlToken

      included do
        field :admin, type: Boolean, default: false
        field :super_admin, type: Boolean, default: false
        field :releases_access, type: Boolean, default: false
        field :store_access, type: Boolean, default: false
        field :catalog_access, type: Boolean, default: false
        field :search_access, type: Boolean, default: false
        field :orders_access, type: Boolean, default: false
        field :people_access, type: Boolean, default: false
        field :settings_access, type: Boolean, default: false
        field :reports_access, type: Boolean, default: false
        field :marketing_access, type: Boolean, default: false
        field :orders_management_access, type: Boolean, default: false
        field :help_admin, type: Boolean, default: false
        field :permissions_manager, type: Boolean, default: false
        field :can_publish_now, type: Boolean
        field :can_restore, type: Boolean
        field :status_email_recipient, type: Boolean, default: false
        field :last_impersonated_by_id, type: String
        field :last_impersonated_at, type: Time

        before_validation :set_all_permissions, if: :super_admin?
        before_validation :set_default_admin_permissions, if: :admin?
        before_save :reset_permissions_if_no_longer_admin

        scope :admins, -> { where(admin: true) }
        index({ admin: 1 })
      end

      class_methods do
        def status_email_recipients
          admins.where(status_email_recipient: true)
        end
      end

      def mark_impersonated_by!(user)
        update_attributes!(
          last_impersonated_by_id: user.id,
          last_impersonated_at: Time.current
        )
      end

      private

      def set_all_permissions
        Workarea.config.permissions_fields.each do |field|
          send("#{field}=", true)
        end
      end

      def set_default_admin_permissions
        self.can_publish_now = true if can_publish_now.nil?
        self.can_restore = true if can_restore.nil?
      end

      def reset_permissions_if_no_longer_admin
        if admin_was && !admin
          Workarea.config.permissions_fields.each do |field|
            send("#{field}=", false)
          end

          self.token = self.class.generate_unique_secure_token
        end
      end
    end
  end
end
