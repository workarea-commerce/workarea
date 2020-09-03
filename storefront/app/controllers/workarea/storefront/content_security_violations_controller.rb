module Workarea
  module Storefront
    class ContentSecurityViolationsController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        if persist_report?
          violations_params.each do |violation_params|
            violation = Content::SecurityViolation.find_or_initialize_by(
              blocked_uri: violation_params['blocked_uri']
            )

            violation.update!(violation_params)
          end
        end

        head :created
      end

      private

      def persist_report?
        Workarea.config.report_content_security_violations &&
          violations_params.present?
      end

      def violations_params
        @violation_params ||=
          if params['csp-report'].present?
            [permit_report_params(params['csp-report'])]
          elsif params['_json'].present?
            permit_report_to_params
          end
      end

      def permit_report_to_params
        params['_json'].map do |violation|
          body = violation['body']

          permit_report_params(body)
            .reverse_merge(
              blocked_uri: body['blocked'],
              document_uri: violation['url'],
              original_policy: body['policy'],
              status_code: body['status'],
              violated_directive: body['directive']
            )
        end
      end

      def permit_report_params(report_params)
        report_params
          .permit(*%w(
            blocked-uri
            disposition
            document-uri
            effective-directive
            original-policy
            referrer
            script-sample
            status-code
            violated-directive
          ))
          .to_h
          .transform_keys { |k| k.optionize }
      end
    end
  end
end
