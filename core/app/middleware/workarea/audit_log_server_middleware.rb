module Workarea
  class AuditLogServerMiddleware
    def call(worker, msg, queue)
      return yield if msg['current_modifier_id'].blank?
      user = User.find(msg['current_modifier_id']) rescue nil

      if user.blank?
        yield
      else
        Mongoid::AuditLog.record(user) { yield }
      end
    end
  end
end
