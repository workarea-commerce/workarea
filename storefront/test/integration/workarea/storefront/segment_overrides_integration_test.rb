require 'test_helper'

module Workarea
  module Storefront
    class SegmentOverridesIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

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
        refute_includes(response.body, product.id)

        get storefront.root_path
        refute_includes(response.body, '<p>Foo</p>')
      end

      def test_impersonation_segments
        create_life_cycle_segments
        first_time_visitor = Segment::FirstTimeVisitor.instance
        customer = create_user
        super_admin = create_user(password: 'W3bl1nc!', super_admin: true)
        post storefront.login_path, params: { email: super_admin.email, password: 'W3bl1nc!' }
        post admin.impersonations_path, params: { user_id: customer.id }

        get storefront.current_user_path(format: 'json')
        assert(response.headers['X-Workarea-Segments'].blank?)

        post admin.segment_override_path,
          params: { segment_ids: { first_time_visitor.id => 'true' } }

        get storefront.current_user_path(format: 'json')
        assert_equal(first_time_visitor.id, response.headers['X-Workarea-Segments'])
      end
    end
  end
end
