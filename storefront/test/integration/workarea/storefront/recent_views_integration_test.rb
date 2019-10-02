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
    end
  end
end
