require 'test_helper'

module Workarea
  module Storefront
    class ContentSecurityPolicyIntegrationTest < Workarea::IntegrationTest
      def test_create_from_report_uri
        post storefront.content_security_violations_path,
             params: {
               'csp-report' => {
                 'blocked-uri' => 'http://example.com/foo.js',
                 'document-uri' => 'http://yoursite.com/pages/foo',
                 'violated-directive' => 'default-src'
               }
             }

        assert_equal(0, Content::SecurityViolation.count)

        Workarea.config.report_content_security_violations = true

        post storefront.content_security_violations_path,
             params: {
               'csp-report' => {
                 'blocked-uri' => 'http://example.com/foo.js',
                 'document-uri' => 'http://yoursite.com/pages/foo',
                 'violated-directive' => 'default-src'
               }
             }

        assert_equal(1, Content::SecurityViolation.count)

        violation = Content::SecurityViolation.first
        assert_equal('http://example.com/foo.js', violation.blocked_uri)
        assert_equal('http://yoursite.com/pages/foo', violation.document_uri)
        assert_equal('default-src', violation.violated_directive)
      end

      def test_create_from_report_to
        Workarea.config.report_content_security_violations = true

        post storefront.content_security_violations_path,
             headers: { 'Content-Type' => 'application/report+json' },
             params: [{
               type: 'csp',
               url: 'http://yoursite.com/pages/foo',
               body: {
                 blocked: 'http://example.com/foo.js',
                 directive: 'default-src',
                 policy: %w(default-src 'self')
               }
             }].to_json

        assert_equal(1, Content::SecurityViolation.count)

        violation = Content::SecurityViolation.first
        assert_equal('http://example.com/foo.js', violation.blocked_uri)
        assert_equal('http://yoursite.com/pages/foo', violation.document_uri)
        assert_equal('default-src', violation.violated_directive)
      end
    end
  end
end
