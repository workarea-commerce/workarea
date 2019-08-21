module Workarea
  class AuditLogClientMiddleware
    def call(worker, msg, *)
      msg['current_modifier_id'] = Mongoid::AuditLog.current_modifier&.id&.to_s
      yield
    end
  end
end
