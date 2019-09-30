require 'test_helper'

module Workarea
  module Storefront
    class RecentViewsIntegrationTest < Workarea::IntegrationTest
      include Storefront::IntegrationTest

      def test_show
        password = 'W3bl1nc!'
        user = create_user(password: password)
        category = create_category
        href = storefront.product_path(product, via: category.id)

        post storefront.login_path, params: {
          email: user.email,
          password: password
        }

        assert_redirected_to(storefront.users_account_path)
        refute(session[:user_id].blank?)

        Metrics::User.save_affinity(
          id: user.email,
          action: 'viewed',
          product_ids: [product.id]
        )

        get storefront.recent_views_path(via: category.id)

        assert_response(:success)
        assert_select('.recent-views__section--products')
        assert_select('.product-summary')
        assert_select(%(.product-summary__name a[href="#{href}"]))
      end
    end
  end
end
