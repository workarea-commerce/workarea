require 'test_helper'

module Workarea
  class ErrorReportingTest < TestCase
    class ReporterDouble
      attr_reader :calls

      def initialize(raises: false)
        @raises = raises
        @calls = []
      end

      def report(error, handled:, severity:, context:)
        raise StandardError, 'reporter failure' if @raises

        @calls << {
          error: error,
          handled: handled,
          severity: severity,
          context: context
        }

        :reported
      end
    end

    def test_report_forwards_to_rails_error_when_available
      error = StandardError.new('boom')
      reporter = ReporterDouble.new

      Rails.stub(:error, reporter) do
        result = Workarea::ErrorReporting.report(
          error,
          handled: true,
          severity: :warning,
          context: { service: 'rubygems.org' }
        )

        assert_equal(:reported, result)
        assert_equal(1, reporter.calls.length)
        assert_equal(error, reporter.calls.first[:error])
        assert_equal(true, reporter.calls.first[:handled])
        assert_equal(:warning, reporter.calls.first[:severity])
        assert_equal({ service: 'rubygems.org' }, reporter.calls.first[:context])
      end
    end

    def test_report_returns_nil_when_rails_error_is_unavailable
      error = StandardError.new('boom')

      Rails.stub(:error, nil) do
        assert_nil(Workarea::ErrorReporting.report(error))
      end
    end

    def test_report_swallows_reporter_failures
      error = StandardError.new('boom')
      reporter = ReporterDouble.new(raises: true)

      Rails.stub(:error, reporter) do
        assert_nil(Workarea::ErrorReporting.report(error))
      end
    end
  end
end
