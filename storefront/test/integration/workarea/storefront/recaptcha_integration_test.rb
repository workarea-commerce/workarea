require 'test_helper'

module Workarea
  module Storefront
    class RecaptchaIntegrationTest < Workarea::IntegrationTest
      setup :enable_recaptcha
      teardown :disable_recaptcha

      def enable_recaptcha
        ::Recaptcha.configuration.skip_verify_env.delete('test')
      end

      def disable_recaptcha
        ::Recaptcha.configuration.skip_verify_env << 'test'
      end

      def setup_v3
        Workarea.config.recaptcha_v3_site_key = 'v3_site'
        Workarea.config.recaptcha_v3_secret_key = 'v3_secret'
        Workarea.config.recaptcha_v3_minimum_score = 0.5
      end

      def setup_v2
        Workarea.config.recaptcha_v2_site_key = 'v2_site'
        Workarea.config.recaptcha_v2_secret_key = 'v2_secret'
      end

      def test_recaptcha_v3
        setup_v3

        cassette_options = {
          secret_key: Workarea.config.recaptcha_v3_secret_key,
          success: true,
          action: 'contact',
          response: 'foo'
        }

        VCR.use_cassette 'recaptcha', erb: cassette_options.merge(score: 0.9) do
          post storefront.contact_path,
            params: {
              name: 'Ben Crouse',
              email: 'bcrouse@workarea.com',
              subject: 'orders',
              order_id: 'ORDER123',
              message: 'test message',
              'g-recaptcha-response-data': { contact: 'foo' }
            }

          assert(response.redirect?)
          assert_equal(1, Inquiry.count)
        end

        VCR.use_cassette 'recaptcha', erb: cassette_options.merge(score: 0.4) do
          post storefront.contact_path,
            params: {
              name: 'Ben Crouse',
              email: 'bcrouse@workarea.com',
              subject: 'orders',
              order_id: 'ORDER123',
              message: 'test message',
              'g-recaptcha-response-data': { contact: 'foo' }
            }

          assert_equal(422, response.status)
          assert_equal(1, Inquiry.count)
        end
      end

      def test_recaptcha_v3_with_fallback
        setup_v3
        setup_v2

        cassette_options = {
          secret_key: Workarea.config.recaptcha_v3_secret_key,
          success: true,
          action: 'contact',
          response: 'foo'
        }

        VCR.use_cassette 'recaptcha', erb: cassette_options.merge(score: 0.4) do
          post storefront.contact_path,
            params: {
              name: 'Ben Crouse',
              email: 'bcrouse@workarea.com',
              subject: 'orders',
              order_id: 'ORDER123',
              message: 'test message',
              'g-recaptcha-response-data': { contact: 'foo' }
            }

          assert_equal(422, response.status)
          assert_equal(0, Inquiry.count)
          assert_includes(response.body, Workarea.config.recaptcha_v2_site_key)
        end
      end

      def test_recaptcha_v2
        setup_v2
        secret_key = { secret_key: Workarea.config.recaptcha_v2_secret_key }

        VCR.use_cassette 'recaptcha', erb: secret_key.merge(success: true, response: 'foo') do
          post storefront.contact_path,
            params: {
              name: 'Ben Crouse',
              email: 'bcrouse@workarea.com',
              subject: 'orders',
              order_id: 'ORDER123',
              message: 'test message',
              'g-recaptcha-response': 'foo'
            }

          assert(response.redirect?)
          assert_equal(1, Inquiry.count)
        end

        VCR.use_cassette 'recaptcha', erb: secret_key.merge(success: false, response: 'foo') do
          post storefront.contact_path,
            params: {
              name: 'Ben Crouse',
              email: 'bcrouse@workarea.com',
              subject: 'orders',
              order_id: 'ORDER123',
              message: 'test message',
              'g-recaptcha-response': 'foo'
            }

          assert_equal(422, response.status)
          assert_equal(1, Inquiry.count)
        end
      end
    end
  end
end
