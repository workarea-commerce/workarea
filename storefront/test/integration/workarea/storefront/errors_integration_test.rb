require 'test_helper'

module Workarea
  module Storefront
    class ErrorsIntegrationTest < Workarea::IntegrationTest
      setup :remove_error_static_files
      teardown :move_error_static_files_back

      def remove_error_static_files
        %w(404 500).each do |type|
          begin
            FileUtils.mv(
              Rails.root.join('public', "#{type}.html"),
              Rails.root.join('public', "#{type}_tmp.html")
            )

          rescue Errno::ENOENT
            # noop
          end
        end
      end

      def move_error_static_files_back
        %w(404 500).each do |type|
          begin
            FileUtils.mv(
              Rails.root.join('public', "#{type}_tmp.html"),
              Rails.root.join('public', "#{type}.html")
            )

          rescue Errno::ENOENT
            # noop
          end
        end
      end

      def test_custom_not_found
        not_found = Content.for('Not Found')
        not_found.blocks.build(
          type: :html,
          data: { html: 'Foo bar' }
        )
        not_found.save!

        get storefront.not_found_path,
          env: { 'action_dispatch.original_path' => 'foo' }

        assert_equal(404, response.status)
        assert_includes(response.body, 'Foo bar')
      end

      def test_custom_internal_error
        internal_error = Content.for('Internal Server Error')
        internal_error.blocks.build(
          type: :html,
          data: { html: 'Foo bar' }
        )
        internal_error.save!

        error = RuntimeError.new('test')

        get storefront.internal_error_path,
          env: { 'action_dispatch.exception' => error }

        assert_equal(500, response.status)
        assert_equal(error, request.env['rack.exception'])
        assert_includes(response.body, 'Foo bar')

        get storefront.internal_error_path(format: :json),
          env: { 'action_dispatch.exception' => error }

        assert_equal(500, response.status)
        assert_equal(error, request.env['rack.exception'])
        assert_empty(response.body)
      end

      def test_on_demand_content_creation
        get storefront.not_found_path,
          env: { 'action_dispatch.original_path' => 'foo' }

        assert_equal(404, response.status)
        assert_includes(response.body, 'Not Found')

        error = RuntimeError.new('test')
        get storefront.internal_error_path,
          env: { 'action_dispatch.exception' => error }

        assert_equal(500, response.status)
        assert_equal(error, request.env['rack.exception'])
        assert_includes(response.body, 'Internal Server Error')
      end

      def test_redirects
        page = create_page(slug: 'faq')
        create_redirect(
          path: storefront.product_path('foo-bar'),
          destination: storefront.page_path(page)
        )

        get storefront.not_found_path,
          env: {
            'action_dispatch.original_path' => storefront.product_path('foo-bar')
          }

        assert_redirected_to(storefront.page_path(page))
        assert_equal(301, response.status)

        create_redirect(
          path: storefront.product_path('foo-bar', foo: 'bar'),
          destination: storefront.page_path(page, foo: 'bar')
        )

        get storefront.not_found_path,
          env: {
            'action_dispatch.original_path' => storefront.product_path('foo-bar', foo: 'bar')
          }

        assert_redirected_to(storefront.page_path(page, foo: 'bar'))
        assert_equal(301, response.status)
      end

      def test_pwa_network_offline_error
        offline = Content.for('Offline')
        offline.blocks.build(
          type: :html,
          data: { html: 'Foo bar' }
        )
        offline.save!

        get storefront.offline_path

        assert_equal(200, response.status)
        assert_includes(response.body, 'Foo bar')
      end
    end
  end
end
