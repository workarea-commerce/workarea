# frozen_string_literal: true

module Workarea
  # Small wrapper around Rails 7.1+'s error reporting API.
  #
  # Rails.error.report is an additive mechanism which can be configured by host
  # applications (or plugins) to forward handled exceptions to Sentry, Bugsnag,
  # etc. Workarea itself intentionally does not hard-code a specific provider.
  module ErrorReporting
    class << self
      # @param error [Exception]
      # @param handled [Boolean] whether the exception was handled/swallowed
      # @param severity [Symbol] :error, :warning, :info
      # @param context [Hash] additional structured context
      def report(error, handled: true, severity: :error, context: {})
        return unless rails_error_reporter_available?

        Rails.error.report(
          error,
          handled: handled,
          severity: severity,
          context: context
        )
      rescue StandardError
        # Never allow error reporting failures to impact runtime behavior.
        nil
      end

      private

      def rails_error_reporter_available?
        defined?(Rails) && Rails.respond_to?(:error) && Rails.error.respond_to?(:report)
      end
    end
  end
end
