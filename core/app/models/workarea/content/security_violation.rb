module Workarea
  class Content
    class SecurityViolation
      include ApplicationDocument

      field :blocked_uri, type: String
      field :disposition, type: String
      field :document_uri, type: String
      field :effective_directive, type: String
      field :original_policy, type: String
      field :referrer, type: String
      field :script_sample, type: String
      field :status_code, type: String
      field :violated_directive, type: String

      index(blocked_uri: 1)
      index(
        { updated_at: 1 },
        { expire_after_seconds: Workarea.config.content_security_violation_expiration }
      )
    end
  end
end
