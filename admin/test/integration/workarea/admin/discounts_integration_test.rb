require 'test_helper'

module Workarea
  module Admin
    class DiscountsIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      def test_updates_a_discount
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        patch admin.pricing_discount_path(discount),
          params: {
            discount: {
              name: 'Edit Test Discount',
              shipping_service: 'Next Day',
              amount: 4
            }
          }

        discount.reload
        assert_equal('Edit Test Discount', discount.name)
        assert_equal('Next Day', discount.shipping_service)
        assert_equal(4.to_m, discount.amount)
      end

      def test_update_with_allowed_template_param
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        # 'rules' is an allowed template; invalid data triggers render
        patch admin.pricing_discount_path(discount),
          params: {
            template: 'rules',
            discount: { name: '' } # empty name causes validation failure
          }

        # Should render the 'rules' template, not raise or redirect to arbitrary path
        assert_response :unprocessable_entity
      end

      def test_invalid_update_with_rules_template_renders_rules_template
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        # template=rules on invalid update must render the :rules template (422)
        patch admin.pricing_discount_path(discount),
          params: {
            template: 'rules',
            discount: { name: '' }
          }

        assert_response :unprocessable_entity
        # The rules template embeds a hidden field so the form re-submits to
        # the same template on retry — this distinguishes it from :edit
        assert_select("input[name='template'][value='rules']")
      end

      def test_invalid_update_without_template_param_renders_edit_template
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        # No template param — controller falls through to else → renders :edit (422)
        patch admin.pricing_discount_path(discount),
          params: { discount: { name: '' } }

        assert_response :unprocessable_entity
        # edit template does NOT embed a hidden template field
        assert_select("input[name='template']", false)
      end

      def test_invalid_update_with_arbitrary_template_param_renders_edit_template
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        # Arbitrary/unknown template param must fall back to :edit (422)
        patch admin.pricing_discount_path(discount),
          params: {
            template: 'arbitrary_string',
            discount: { name: '' }
          }

        assert_response :unprocessable_entity
        # edit template does NOT embed a hidden template field
        assert_select("input[name='template']", false)
      end

      def test_update_with_disallowed_template_param_falls_back_to_edit
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        # An unknown/disallowed template must fall back to :edit safely
        patch admin.pricing_discount_path(discount),
          params: {
            template: '../../etc/passwd',
            discount: { name: '' }
          }

        assert_response :unprocessable_entity
      end

      def test_removes_a_discount
        discount = create_shipping_discount(
          name: 'Test Discount',
          active: true,
          shipping_service: 'Ground',
          amount: 5
        )

        delete admin.pricing_discount_path(discount)
        assert(Pricing::Discount.empty?)
      end

      def test_autocompletes_partial_queries_when_xhr
        discount = create_product_discount(name: 'Test')
        create_top_discounts(results: [{ discount_id: discount.id }])

        get admin.pricing_discounts_path(format: 'json', q: 'tes'), xhr: true

        results = JSON.parse(response.body)
        assert_equal(1, results['results'].length)
        assert(results['results'].first['label'].present?)
        assert_equal(discount.id.to_s, results['results'].first['value'])
        assert(results['results'].first['top'])
      end
    end
  end
end
