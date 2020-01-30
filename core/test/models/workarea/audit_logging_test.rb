require 'test_helper'

module Workarea
  class AuditLoggingTest < TestCase
    class FooModel
      include Mongoid::Document
      include AuditLogging

      field :name, type: String
    end

    def test_audit_log_recording
      Mongoid::AuditLog.record do
        FooModel.create!(name: 'bar')
        assert_equal(1, Mongoid::AuditLog::Entry.count)

        FooModel.disable_audit_log

        FooModel.create!(name: 'bar')
        assert_equal(1, Mongoid::AuditLog::Entry.count)

        FooModel.enable_audit_log

        FooModel.create!(name: 'bar')
        assert_equal(2, Mongoid::AuditLog::Entry.count)
      end
    end
  end
end
