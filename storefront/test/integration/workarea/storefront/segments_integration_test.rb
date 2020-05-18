require 'test_helper'

module Workarea
  module Storefront
    class SegmentsIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_life_cycle_segments_functionality
        Workarea.config.loyal_customers_min_orders = 3
        create_life_cycle_segments

        get storefront.current_user_path(format: 'json')
        assert_equal(
          Segment::FirstTimeVisitor.instance.id.to_s,
          response.headers['X-Workarea-Segments']
        )

        cookies[:sessions] = 2
        get storefront.current_user_path(format: 'json')
        assert_equal(
          Segment::ReturningVisitor.instance.id.to_s,
          response.headers['X-Workarea-Segments']
        )

        complete_checkout

        get storefront.current_user_path(format: 'json')
        assert_equal(
          Segment::FirstTimeCustomer.instance.id.to_s,
          response.headers['X-Workarea-Segments']
        )

        complete_checkout

        get storefront.current_user_path(format: 'json')
        assert_equal(
          Segment::ReturningCustomer.instance.id.to_s,
          response.headers['X-Workarea-Segments']
        )

        complete_checkout

        get storefront.current_user_path(format: 'json')
        assert_equal(
          Segment::LoyalCustomer.instance.id.to_s,
          response.headers['X-Workarea-Segments']
        )
      end

      def test_products_active_by_segment
        segment_one = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 1, maximum: 1)])
        segment_two = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 2, maximum: 2)])
        product_one = create_product(active: true, active_segment_ids: [segment_two.id])
        product_two = create_product(active: true, active_segment_ids: [segment_one.id])

        assert_raise InvalidDisplay do
          cookies[:sessions] = 0
          get storefront.product_path(product_one)
          assert(response.not_found?)
        end

        assert_raise InvalidDisplay do
          cookies[:sessions] = 0
          get storefront.product_path(product_two)
          assert(response.not_found?)
        end

        cookies[:sessions] = 0
        get storefront.search_path(q: '*')
        refute_includes(response.body, product_one.id)
        refute_includes(response.body, product_two.id)

        assert_raise InvalidDisplay do
          cookies[:sessions] = 1
          get storefront.product_path(product_one)
          assert(response.not_found?)
        end

        cookies[:sessions] = 1
        get storefront.product_path(product_two)
        assert(response.ok?)

        cookies[:sessions] = 1
        get storefront.search_path(q: '*')
        refute_includes(response.body, product_one.id)
        assert_includes(response.body, product_two.id)

        cookies[:sessions] = 2
        get storefront.product_path(product_one)
        assert(response.ok?)

        assert_raise InvalidDisplay do
          cookies[:sessions] = 2
          get storefront.product_path(product_two)
          assert(response.not_found?)
        end

        cookies[:sessions] = 2
        get storefront.search_path(q: '*')
        assert_includes(response.body, product_one.id)
        refute_includes(response.body, product_two.id)

        segment_one.rules.first.update!(minimum: 1, maximum: nil)
        segment_two.rules.first.update!(minimum: 1, maximum: nil)

        cookies[:sessions] = 1
        get storefront.product_path(product_one)
        assert(response.ok?)

        cookies[:sessions] = 1
        get storefront.product_path(product_two)
        assert(response.ok?)

        cookies[:sessions] = 1
        get storefront.search_path(q: '*')
        assert_includes(response.body, product_one.id)
        assert_includes(response.body, product_two.id)
      end

      def test_content_active_by_segment
        segment_one = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 1, maximum: 1)])
        segment_two = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 2, maximum: 2)])

        content = Content.for('home_page')
        content.blocks.create!(
          type: 'html',
          data: { 'html' => '<p>Foo</p>' },
          active_segment_ids: [segment_one.id]
        )
        content.blocks.create!(
          type: 'html',
          data: { 'html' => '<p>Bar</p>' },
          active_segment_ids: [segment_two.id]
        )

        cookies[:sessions] = 1
        get storefront.root_path
        assert_includes(response.body, '<p>Foo</p>')
        refute_includes(response.body, '<p>Bar</p>')

        cookies[:sessions] = 2
        get storefront.root_path
        refute_includes(response.body, '<p>Foo</p>')
        assert_includes(response.body, '<p>Bar</p>')

        segment_one.rules.first.update!(minimum: 1, maximum: nil)
        segment_two.rules.first.update!(minimum: 1, maximum: nil)
        cookies[:sessions] = 1
        get storefront.root_path
        assert_includes(response.body, '<p>Foo</p>')
        assert_includes(response.body, '<p>Bar</p>')
      end

      def test_logged_in_based_segments
        logged_in = create_segment(rules: [Segment::Rules::LoggedIn.new(logged_in: true)])
        logged_out = create_segment(rules: [Segment::Rules::LoggedIn.new(logged_in: false)])

        get storefront.current_user_path(format: 'json')
        assert_equal(logged_out.id.to_s, response.headers['X-Workarea-Segments'])

        user = create_user(password: 'w0rkArea!')
        post storefront.login_path,
          params: { email: user.email, password: 'w0rkArea!' }

        get storefront.current_user_path(format: 'json')
        assert_equal(logged_in.id.to_s, response.headers['X-Workarea-Segments'])
      end

      def test_endpoints_without_a_visit
        assert_nothing_raised do
          get storefront.internal_error_path(format: 'png')
          refute(response.headers.key?('X-Workarea-Segments'))
        end
      end

      def test_segmented_discounts
        new_visitors = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 0)])
        returning_visitors = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 2)])
        product = create_product(variants: [{ sku: 'SKU', regular: 5.to_m }])
        discount = create_product_discount(
          amount_type: 'flat',
          amount: 1.to_m,
          product_ids: [product.id],
          active: true,
          active_segment_ids: [returning_visitors.id]
        )

        post storefront.cart_items_path,
           params: { product_id: product.id, sku: product.skus.first, quantity: 1 }

        order = Order.first
        assert_equal(5.to_m, order.total_price)

        cookies[:sessions] = 2
        get storefront.cart_path # reprice the order
        assert_equal(4.to_m, order.reload.total_price)
      end

      def test_http_caching_headers_for_segmented_content
        Workarea.config.strip_http_caching_in_tests = false
        segment = create_segment(rules: [Segment::Rules::Sessions.new(maximum: 999)])

        get storefront.root_path
        refute_match(/private/, response.headers['Cache-Control'])
        assert_match(/public/, response.headers['Cache-Control'])
        assert(response.headers['X-Workarea-Segmented-Content'].blank?)

        content = Content.for('home_page')
        content.blocks.create!(
          type: 'html',
          data: { 'html' => '<p>Foo</p>' },
          active_segment_ids: [segment.id]
        )

        get storefront.root_path
        assert_match(/private/, response.headers['Cache-Control'])
        refute_match(/public/, response.headers['Cache-Control'])
        assert_equal('true', response.headers['X-Workarea-Segmented-Content'])

        product = create_product(active: true, active_segment_ids: [])
        get storefront.product_path(product)
        assert(response.ok?)
        refute_match(/private/, response.headers['Cache-Control'])
        assert_match(/public/, response.headers['Cache-Control'])
        assert(response.headers['X-Workarea-Segmented-Content'].blank?)

        product.update!(active_segment_ids: [segment.id])
        get storefront.product_path(product)
        assert(response.ok?)
        assert_match(/private/, response.headers['Cache-Control'])
        refute_match(/public/, response.headers['Cache-Control'])
        assert_equal('true', response.headers['X-Workarea-Segmented-Content'])

        category = create_category(active: true, active_segment_ids: [])
        get storefront.category_path(category)
        assert(response.ok?)
        refute_match(/private/, response.headers['Cache-Control'])
        assert_match(/public/, response.headers['Cache-Control'])
        assert(response.headers['X-Workarea-Segmented-Content'].blank?)

        category.update!(product_ids: [product.id])
        get storefront.category_path(category)
        assert(response.ok?)
        assert_match(/private/, response.headers['Cache-Control'])
        refute_match(/public/, response.headers['Cache-Control'])
        assert_equal('true', response.headers['X-Workarea-Segmented-Content'])
      end

      def test_referrer_based_segments
        google = create_segment(rules: [Segment::Rules::TrafficReferrer.new(source: %w(Google))])
        facebook = create_segment(rules: [Segment::Rules::TrafficReferrer.new(url: 'facebook')])

        get storefront.current_user_path(format: 'json'),
          headers: { 'HTTP_REFERER' => 'https://www.google.com/' }
        assert_equal(google.id.to_s, response.headers['X-Workarea-Segments'])

        get storefront.current_user_path(format: 'json'),
          headers: { 'HTTP_REFERER' => 'https://www.facebook.com/' }
        assert_equal(facebook.id.to_s, response.headers['X-Workarea-Segments'])

        cookies[:workarea_referrer] = 'https://www.google.com/'
        get storefront.current_user_path(format: 'json')
        assert_equal(google.id.to_s, response.headers['X-Workarea-Segments'])

        cookies[:workarea_referrer] = 'https://www.facebook.com/'
        get storefront.current_user_path(format: 'json')
        assert_equal(facebook.id.to_s, response.headers['X-Workarea-Segments'])

        cookies[:workarea_referrer] = 'https://www.google.com/'
        get storefront.current_user_path(format: 'json'),
          headers: { 'HTTP_REFERER' => 'https://www.facebook.com/' }
        assert_equal(google.id.to_s, response.headers['X-Workarea-Segments'])
      end

      def test_missing_email_cookies
        user = create_user(password: 'w0rkArea!', tags: %w(foo))
        segment = create_segment(rules: [Segment::Rules::Tags.new(tags: %w(foo))])

        post storefront.login_path,
          params: { email: user.email, password: 'w0rkArea!' }

        cookies[:email] = nil

        get storefront.current_user_path(format: 'json')
        assert_equal(segment.id.to_s, response.headers['X-Workarea-Segments'])
      end
    end
  end
end
