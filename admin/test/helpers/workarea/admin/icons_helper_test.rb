require 'test_helper'

module Workarea
  module Admin
    class IconsHelperTest < ViewTest
      include Admin::Engine.routes.url_helpers

      def current_user
        @user ||= create_user(admin: true)
      end

      def inline_svg_tag(path, options = {})
        [path, *options.values]
      end

      def link_to(content, path, options = {})
        [*content, path, *options.values]
      end

      def insights_path_for(model)
        ''
      end

      def test_comments_icon_for
        page = create_page
        comment = create_comment(commentable: page)

        view_model = PageViewModel.wrap(page)
        result = comments_icon_for(view_model)

        assert_equal('workarea/admin/icons/comments.svg', result.first)
        assert_equal(t('workarea.admin.comments.icon.unviewed'), result.second)

        comment.update(viewed_by_ids: [current_user.id])

        view_model = PageViewModel.wrap(page)
        result = comments_icon_for(view_model)

        assert_equal('workarea/admin/icons/comments_viewed.svg', result.first)
        assert_equal(t('workarea.admin.comments.icon.viewed'), result.second)
      end

      def test_top_icon_for
        product = create_product
        assert_nil(top_icon_for(ProductViewModel.wrap(product)))

        create_top_products(results: [{ product_id: product.id }])
        result = top_icon_for(ProductViewModel.wrap(product))
        assert_equal('workarea/admin/icons/star.svg', result.first)
      end

      def test_trending_icon_for
        product = create_product
        assert_nil(trending_icon_for(ProductViewModel.wrap(product)))

        create_trending_products(results: [{ product_id: product.id }])
        result = trending_icon_for(ProductViewModel.wrap(product))
        assert_equal('workarea/admin/icons/fire.svg', result.first)
      end

      def test_fraud_icon_for
        order = create_order
        assert_nil(fraud_icon_for(order))

        order = create_order(fraud_suspected_at: Time.current)
        result = fraud_icon_for(order)
        assert_equal('workarea/admin/icons/alert.svg', result.first)
      end
    end
  end
end
