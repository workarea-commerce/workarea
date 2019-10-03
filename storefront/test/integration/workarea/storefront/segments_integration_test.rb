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
        segments = response.headers['X-Workarea-Segments'].split(',')
        assert_equal(2, segments.size)
        assert_includes(segments, Segment::FirstTimeCustomer.instance.id.to_s)
        assert_includes(segments, Segment::ReturningVisitor.instance.id.to_s)

        complete_checkout

        get storefront.current_user_path(format: 'json')
        segments = response.headers['X-Workarea-Segments'].split(',')
        assert_equal(2, segments.size)
        assert_includes(segments, Segment::ReturningVisitor.instance.id.to_s)
        assert_includes(segments, Segment::ReturningCustomer.instance.id.to_s)

        complete_checkout

        get storefront.current_user_path(format: 'json')
        segments = response.headers['X-Workarea-Segments'].split(',')
        assert_equal(3, segments.size)
        assert_includes(segments, Segment::ReturningVisitor.instance.id.to_s)
        assert_includes(segments, Segment::ReturningCustomer.instance.id.to_s)
        assert_includes(segments, Segment::LoyalCustomer.instance.id.to_s)
      end

      def test_products_active_by_segment
        segment_one = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 1, maximum: 1)])
        segment_two = create_segment(rules: [Segment::Rules::Sessions.new(minimum: 2, maximum: 2)])
        product_one = create_product(active: true, active_segment_ids: [segment_two.id])
        product_two = create_product(active: true, active_segment_ids: [segment_one.id])

        cookies[:sessions] = 0
        get storefront.product_path(product_one)
        assert(response.ok?)

        cookies[:sessions] = 0
        get storefront.product_path(product_two)
        assert(response.ok?)

        cookies[:sessions] = 0
        get storefront.search_path(q: '*')
        assert_includes(response.body, product_one.id)
        assert_includes(response.body, product_two.id)

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

      def test_admins_ignore_segments
        create_life_cycle_segments
        first_time_visitor = Segment::FirstTimeVisitor.instance
        returning_visitor = Segment::ReturningVisitor.instance
        product = create_product(active: true, active_segment_ids: [returning_visitor.id])
        content = Content.for('home_page')
        content.blocks.create!(
          type: 'html',
          data: { 'html' => '<p>Foo</p>' },
          active_segment_ids: [returning_visitor.id]
        )

        set_current_user(create_user(admin: true))

        get storefront.search_path(q: '*')
        assert_includes(response.body, product.id)

        get storefront.root_path
        assert_includes(response.body, '<p>Foo</p>')
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
    end
  end
end
