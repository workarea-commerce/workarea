module Workarea
  module Storefront
    module ContentSecurityPolicy
      extend ActiveSupport::Concern

      included do
        after_action :set_content_security_policy, if: -> { request.get? }
      end

      private

      def set_content_security_policy
        policy = content_security_policy
        return unless policy.present?

        if Workarea.config.enforce_content_security_policy
          response.set_header('Content-Security-Policy', policy)
        else
          response.set_header('Content-Security-Policy-Report-Only', policy)
        end

        if Workarea.config.report_content_security_violations
          response.set_header('Report-To', report_to.to_json)
        end
      end

      def content_security_policy
        policy = [
          Workarea.config.global_content_security_policy,
          page_specific_content_policy
        ].compact.join(' ')

        return unless policy.present?
        return policy unless Workarea.config.report_content_security_violations

        "#{policy} report-uri #{content_security_violations_path}; report-to csp-endpoint;"
      end

      def page_specific_content_policy
        # no-op, needs to be defined per controller that supports it
      end

      def report_to
        {
          group: 'csp-endpoint',
          max_age: Workarea.config.content_security_violation_expiration,
          endpoints: [{ url: content_security_violations_url }]
        }
      end
    end
  end
end
