require 'test_helper'

module Workarea
  module Storefront
    class ContentSecurityPolicyIntegrationTest < Workarea::IntegrationTest
      def test_policy_header
        Workarea.config.global_content_security_policy = %(default-src 'self';)
        get storefront.root_path

        assert_equal(
          %(default-src 'self';),
          response.headers['Content-Security-Policy']
        )

        Workarea.config.report_content_security_violations = true
        get storefront.root_path

        assert_equal(
          %(default-src 'self'; report-uri #{storefront.content_security_violations_path}; report-to csp-endpoint;),
          response.headers['Content-Security-Policy']
        )

        Workarea.config.enforce_content_security_policy = false
        get storefront.root_path

        assert_nil(response.headers['Content-Security-Policy'])
        assert_equal(
          %(default-src 'self'; report-uri #{storefront.content_security_violations_path}; report-to csp-endpoint;),
          response.headers['Content-Security-Policy-Report-Only']
        )
      end

      def test_policy_for_pages
        page = create_page
        content = Content.for(page)

        Workarea.config.global_content_security_policy = %(default-src 'self';)

        content.update!(content_security_policy: %(child-src 'none';))

        get storefront.page_path(page)

        assert_equal(
          %(default-src 'self'; child-src 'none';),
          response.headers['Content-Security-Policy']
        )

        Workarea.config.report_content_security_violations = true
        get storefront.page_path(page)

        assert_equal(
          %(default-src 'self'; child-src 'none'; report-uri #{storefront.content_security_violations_path}; report-to csp-endpoint;),
          response.headers['Content-Security-Policy']
        )
      end

      def test_policy_for_categories
        category = create_category
        content = Content.for(category)

        Workarea.config.global_content_security_policy = %(default-src 'self';)

        content.update!(content_security_policy: %(child-src 'none';))

        get storefront.category_path(category)

        assert_equal(
          %(default-src 'self'; child-src 'none';),
          response.headers['Content-Security-Policy']
        )

        Workarea.config.report_content_security_violations = true
        get storefront.category_path(category)

        assert_equal(
          %(default-src 'self'; child-src 'none'; report-uri #{storefront.content_security_violations_path}; report-to csp-endpoint;),
          response.headers['Content-Security-Policy']
        )
      end
    end
  end
end
