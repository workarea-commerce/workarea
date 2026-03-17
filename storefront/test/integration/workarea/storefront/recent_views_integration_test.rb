require 'test_helper'

module Workarea
  module Storefront
    class RecentViewsIntegrationTest < Workarea::IntegrationTest
      def test_show
        password = 'W3bl1nc!'
        user = create_user(password: password)
        category = create_category
        product = create_product
        Metrics::User.save_affinity(
          id: user.email,
          action: 'viewed',
          product_ids: [product.id]
        )

        post storefront.login_path,
          params: { email: user.email, password: password }

        assert_redirected_to(storefront.users_account_path)
        refute(session[:user_id].blank?)

        product_url = storefront.product_path(product, via: category.id)
        get storefront.recent_views_path(via: category.id)
        assert_select(%(.product-summary__name a[href="#{product_url}"]))
      end

      def test_show_with_allowed_views
        password = 'W3bl1nc!'
        user = create_user(password: password)

        post storefront.login_path,
          params: { email: user.email, password: password }

        # 'aside' and 'narrow' are allowed alternate views
        %w[aside narrow].each do |view|
          get storefront.recent_views_path(view: view)
          assert_response :success
        end
      end

      def test_show_rejects_disallowed_view_param
        password = 'W3bl1nc!'
        user = create_user(password: password)

        post storefront.login_path,
          params: { email: user.email, password: password }

        # An arbitrary/unknown view param falls back to default :show
        get storefront.recent_views_path(view: '../../etc/passwd')
        assert_response :success
      end

      def test_view_aside_renders_aside_partial
        password = 'W3bl1nc!'
        user = create_user(password: password)
        product = create_product
        Metrics::User.save_affinity(
          id: user.email,
          action: 'viewed',
          product_ids: [product.id]
        )

        post storefront.login_path,
          params: { email: user.email, password: password }

        get storefront.recent_views_path(view: 'aside')

        assert_response :success
        # aside template uses a unique BEM modifier class not present in narrow/show
        assert_select('.recent-views--aside')
      end

      def test_view_narrow_renders_narrow_partial
        password = 'W3bl1nc!'
        user = create_user(password: password)
        product = create_product
        Metrics::User.save_affinity(
          id: user.email,
          action: 'viewed',
          product_ids: [product.id]
        )

        post storefront.login_path,
          params: { email: user.email, password: password }

        get storefront.recent_views_path(view: 'narrow')

        assert_response :success
        # narrow template uses .recent-views but NOT the --aside modifier
        assert_select('.recent-views')
        assert_select('.recent-views--aside', false)
      end

      def test_arbitrary_view_param_falls_back_to_show_template
        password = 'W3bl1nc!'
        user = create_user(password: password)
        product = create_product
        Metrics::User.save_affinity(
          id: user.email,
          action: 'viewed',
          product_ids: [product.id]
        )

        post storefront.login_path,
          params: { email: user.email, password: password }

        # Unknown view param must fall back to :show template
        get storefront.recent_views_path(view: 'arbitrary_value')

        assert_response :success
        # show template wraps products in a .grid; narrow and aside templates do not
        assert_select('.recent-views .grid')
        assert_select('.recent-views--aside', false)
      end
    end
  end
end
