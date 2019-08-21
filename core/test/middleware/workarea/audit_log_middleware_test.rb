require 'test_helper'

module Workarea
  class AuditLogMiddlewareTest < TestCase
    def test_saving_current_modifier
      admin = create_user(admin: true)
      job = {}

      Mongoid::AuditLog.record(admin) do
        AuditLogClientMiddleware.new.call(mock, job, :foo) {}
        assert_equal(admin.id.to_s, job['current_modifier_id'])
      end

      AuditLogServerMiddleware.new.call(mock, job, :foo) do
        assert_equal(admin, Mongoid::AuditLog.current_modifier)
      end
    end
  end
end
