require 'test_helper'

module Workarea
  class BulkAction
    class ProductEditTest < Workarea::TestCase
      def test_updating_attributes_from_settings
        product = create_product(template: 'generic')
        edit = ProductEdit.new(settings: { 'template' => 'clothing' })

        edit.act_on!(product)
        assert_equal(product.reload.template, 'clothing')
      end

      def test_adding_and_removing_tags
        product = create_product(tags: %w(foo bar))
        edit = ProductEdit.new(add_tags: %w(qux), remove_tags: %w(bar))

        edit.act_on!(product)
        assert_equal(product.reload.tags, %w(foo qux))
      end

      def test_adding_and_removing_filters
        product = create_product(filters: { 'color' => 'red' })
        edit = ProductEdit.new(
          remove_filters: %w(color),
          add_filters: %w(size large)
        )

        edit.act_on!(product)
        assert_equal(product.reload.filters, { 'size' => %w(large) })
      end

      def test_adding_and_removing_details
        product = create_product(details: { 'color' => 'red' })
        edit = ProductEdit.new(
          remove_details: %w(color),
          add_details: %w(size large)
        )

        edit.act_on!(product)
        assert_equal(product.reload.details, { 'size' => %w(large) })
      end

      def test_updating_pricing_skus
        product = create_product(
          variants: [
            { sku: 'SKU1', regular: 5.00 },
            { sku: 'SKU2', regular: 10.00 }
          ]
        )
        product_2 = create_product(variants: [{ sku: 'SKU3', regular: 15.00 }])
        pricing = Pricing::Sku.find_or_create_by(id: 'SKU1').tap do |p|
          p.prices.create!(regular: 10.to_m, min_quantity: 2)
        end

        edit = ProductEdit.new(
          pricing: {
            msrp: '19.99',
            'prices' => {
              regular: {
                'action' => 'set',
                'type' => 'flat',
                'amount' => '14.99'
              }
            }
          }
        )

        edit.act_on!(product)
        edit.act_on!(product_2)

        assert_equal(pricing.reload.msrp, 19.99.to_m)
        assert_equal(pricing.prices.first.regular, 14.99.to_m)
        assert_equal(10.to_m, pricing.prices.second.regular)

        pricing_2 = Pricing::Sku.find_or_create_by(id: 'SKU2')
        assert_equal(pricing_2.msrp, 19.99.to_m)
        assert_equal(pricing_2.prices.first.regular, 14.99.to_m)

        pricing_3 = Pricing::Sku.find_or_create_by(id: 'SKU3')
        assert_equal(pricing_3.msrp, 19.99.to_m)
        assert_equal(pricing_3.prices.first.regular, 14.99.to_m)

        pricing.destroy
        pricing_2.destroy

        edit.act_on!(product)
        pricing = Pricing::Sku.find_or_create_by(id: 'SKU1')
        assert_equal(pricing.msrp, 19.99.to_m)
        assert_equal(pricing.prices.first.regular, 14.99.to_m)
      end

      def test_updating_inventory_skus
        product = create_product(variants: [{ sku: 'SKU1', regular: 5.00 }])
        edit = ProductEdit.new(
          inventory: { policy: 'standard', available: 100 }
        )

        edit.act_on!(product)

        inventory = Inventory::Sku.find('SKU1')
        assert_equal(inventory.policy, 'standard')
        assert_equal(inventory.available, 100)
      end

      def test_updating_within_a_release
        release = create_release
        product = create_product(
          tags: %w(foo bar),
          template: 'generic',
          variants: [{ sku: 'SKU1', regular: 5.00 }]
        )

        edit = ProductEdit.new(
          settings: { 'template' => 'clothing' },
          add_tags: %w(qux),
          remove_tags: %w(bar),
          pricing: {
            msrp: '19.99',
            'prices' => {
              regular: {
                'action' => 'set',
                'type' => 'flat',
                'amount' => '14.99'
              }
            }
          },
          inventory: { policy: 'standard', available: 100 },
          release_id: release.id
        )

        edit.act_on!(product)

        product.reload
        pricing = Pricing::Sku.find_or_create_by(id: 'SKU1')
        inventory = Inventory::Sku.find('SKU1')

        assert_equal('generic', product.template)
        assert_equal(%w(foo bar), product.reload.tags)
        assert_equal(5.to_m, pricing.prices.first.regular)

        # Inventory is not releasable
        assert_equal('standard', inventory.policy)
        assert_equal(100, inventory.available)

        Release.with_current(release.id) do
          product.reload
          pricing.reload

          assert_equal('clothing', product.reload.template)
          assert_equal(%w(foo qux), product.reload.tags)
          assert_equal(19.99.to_m, pricing.msrp)
          assert_equal(14.99.to_m, pricing.prices.first.regular)
        end
      end
    end
  end
end
