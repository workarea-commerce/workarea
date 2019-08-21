require 'test_helper'

module Workarea
  module Storefront
    class ReleasesIntegrationTest < Workarea::IntegrationTest
      def test_previewing_releases
        first = create_release(publish_at: 1.day.from_now)
        second = create_release(publish_at: 2.days.from_now)

        product = create_product(name: 'Foo', template: 'generic', description: 'One')
        first.as_current { product.update_attributes!(name: 'Bar', description: 'Two') }
        second.as_current { product.update_attributes!(name: 'Baz') }

        set_current_user(create_user(super_admin: true))

        post admin.release_session_path, params: { release_id: first.id }
        get storefront.product_path(product)
        assert(response.body.include?('Bar'))
        assert(response.body.include?('Two'))

        post admin.release_session_path, params: { release_id: second.id }
        get storefront.product_path(product)
        assert(response.body.include?('Baz'))
        assert(response.body.include?('Two'))
      end

      def test_browsing_featured_categories
        set_current_user(create_user(super_admin: true))
        product_one = create_product(id: 'PROD1', name: 'Foo')
        product_two = create_product(id: 'PROD2', name: 'Bar')
        pricing = Pricing::Sku.find('SKU').prices.first.tap { |p| p.update!(regular: 5) }
        category = create_category(product_ids: [product_one.id, product_two.id])

        get storefront.category_path(category)
        assert_match(/Foo.*Bar/m, response.body)
        assert_includes(response.body, '5.00')

        release = create_release
        release.as_current do
          category.update!(product_ids: [product_two.id, product_one.id])
          product_one.update!(name: 'Baz')
          pricing.update!(regular: 7.99)
        end

        post admin.release_session_path, params: { release_id: release.id }

        get storefront.category_path(category)
        assert_match(/Bar.*Baz/m, response.body)
        assert_includes(response.body, '7.99')
      end

      def test_category_rules_in_releases
        product_one = create_product(id: 'PROD1', name: 'Foo')
        product_two = create_product(id: 'PROD2', name: 'Bar')
        category = create_category(
          product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
        )

        get storefront.category_path(category)
        assert_includes(response.body, 'Foo')
        refute_includes(response.body, 'Bar')

        release = create_release
        release.as_current do
          category.update!(
            product_rules: [{ name: 'search', operator: 'equals', value: 'bar' }]
          )
        end

        post admin.release_session_path, params: { release_id: release.id }

        get storefront.category_path(category)
        refute_includes(response.body, 'Foo')
        assert_includes(response.body, 'Bar')
      end

      def test_searches_with_release_customizations
        set_current_user(create_user(super_admin: true))
        product_one = create_product(id: 'PROD1', name: 'Test Foo')
        product_two = create_product(id: 'PROD2', name: 'Test Bar')
        search_customization = create_search_customization(
          id: 'test',
          query: 'test',
          product_ids: [product_one.id, product_two.id]
        )

        get storefront.search_path(q: 'test')
        assert_match(/Test Foo.*Test Bar/m, response.body)

        release = create_release
        release.as_current do
          search_customization.update!(product_ids: [product_two.id, product_one.id])
          product_one.update!(name: 'Test Baz')
        end

        post admin.release_session_path, params: { release_id: release.id }

        get storefront.search_path(q: 'test')
        assert_match(/Test Bar.*Test Baz/m, response.body)
      end

      def test_rescheduling_releases
        set_current_user(create_user(super_admin: true))
        product_one = create_product(id: 'PROD1', name: 'Foo')
        product_two = create_product(id: 'PROD2', name: 'Bar')
        category = create_category(product_ids: [product_one.id, product_two.id])

        get storefront.category_path(category)
        assert_match(/Foo.*Bar/m, response.body)

        release_one = create_release(publish_at: 1.day.from_now)
        release_one.as_current { category.update!(product_ids: [product_two.id, product_one.id]) }

        release_two = create_release(publish_at: 2.days.from_now)
        release_two.as_current { product_one.update!(name: 'Baz') }

        post admin.release_session_path, params: { release_id: release_one.id }
        get storefront.category_path(category)
        assert_match(/Bar.*Foo/m, response.body)

        post admin.release_session_path, params: { release_id: release_two.id }
        get storefront.category_path(category)
        assert_match(/Bar.*Baz/m, response.body)

        release_one.update!(publish_at: 1.week.from_now)
        post admin.release_session_path, params: { release_id: release_one.id }
        get storefront.category_path(category)
        assert_match(/Bar.*Baz/m, response.body)
      end
    end
  end
end
