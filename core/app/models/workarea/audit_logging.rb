module Workarea
  module AuditLogging
    extend ActiveSupport::Concern
    include Mongoid::AuditLog

    class_methods do
      def enable_audit_log
        @audit_log_enabled = true
      end

      def disable_audit_log
        @audit_log_enabled = false
      end

      def audit_log_enabled?
        !defined?(@audit_log_enabled) || @audit_log_enabled
      end
    end

    private

    def set_audit_log_changes
      return unless self.class.audit_log_enabled?
      super
    end

    def save_audit_log_entry(action)
      return unless self.class.audit_log_enabled?
      super
    end
  end
end
