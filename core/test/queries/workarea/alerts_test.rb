require 'test_helper'

module Workarea
  class AlertsTest < TestCase
    include SearchIndexing

    def test_products_missing_prices
      assert_equal(0, Alerts.new.products_missing_prices)

      product = create_product
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_prices)

      Pricing::Sku.delete_all
      IndexAdminSearch.perform(product)
      assert_equal(1, Alerts.new.products_missing_prices)

      product.update_attributes!(active: false)
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_prices)
    end

    def test_empty_categories
      assert_equal(0, Alerts.new.empty_categories)

      product = create_product
      category = create_category(product_ids: [product.id], product_rules: [])
      IndexAdminSearch.perform(category)
      assert_equal(0, Alerts.new.empty_categories)

      category.update_attributes!(product_ids: [])
      IndexAdminSearch.perform(category)
      assert_equal(1, Alerts.new.empty_categories)
    end

    def test_products_missing_images
      assert_equal(0, Alerts.new.products_missing_images)

      product = create_product(images: [{ image: product_image_file_path }])
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_images)

      product.update_attributes!(images: [])
      IndexAdminSearch.perform(product)
      assert_equal(1, Alerts.new.products_missing_images)

      product.update_attributes!(active: false)
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_images)
    end

    def test_products_missing_descriptions
      assert_equal(0, Alerts.new.products_missing_descriptions)

      product = create_product(description: 'foo bar baz')
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_descriptions)

      product.update_attributes!(description: nil)
      IndexAdminSearch.perform(product)
      assert_equal(1, Alerts.new.products_missing_descriptions)

      product.update_attributes!(active: false)
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_descriptions)
    end

    def test_products_missing_variants
      assert_equal(0, Alerts.new.products_missing_variants)

      product = create_product
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_variants)

      product.update_attributes!(variants: [])
      IndexAdminSearch.perform(product)
      assert_equal(1, Alerts.new.products_missing_variants)
    end

    def test_products_missing_categories
      assert_equal(0, Alerts.new.products_missing_categories)

      product = create_product
      category = create_category(product_ids: [product.id], product_rules: [])
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_categories)

      category.destroy
      IndexAdminSearch.perform(product)
      assert_equal(1, Alerts.new.products_missing_categories)

      product.update_attributes!(active: false)
      IndexAdminSearch.perform(product)
      assert_equal(0, Alerts.new.products_missing_categories)
    end

    def test_products_variants_missing_details
      assert_equal(0, Alerts.new.products_variants_missing_details)

      product = create_product(variants: [{ sku: 'SKU', details: {} }])
      IndexAdminSearch.perform(product)
      assert_equal(1, Alerts.new.products_variants_missing_details)
    end

    def test_products_inconsistent_variant_details
      assert_equal(0, Alerts.new.products_inconsistent_variant_details)

      product = create_product(
        variants: [
          { sku: 'SKU', details: { 'Color' => %w(red), 'Size' => %w(Large) } },
          { sku: 'SKU', details: { 'Color' => %w(red) } }
        ]
      )
      IndexAdminSearch.perform(product)
      assert_equal(1, Alerts.new.products_inconsistent_variant_details)
    end

    def test_empty_upcoming_releases
      create_release(publish_at: nil) # unscheduled
      empty = create_release(publish_at: 1.hour.from_now)
      has_changes = create_release(publish_at: 1.hour.from_now)

      page = create_page(name: 'Foo')
      Release.with_current(has_changes.id) do
        page.update_attributes!(name: 'Bar')
      end

      assert_equal([empty], Alerts.new.empty_upcoming_releases)
    end

    def test_missing_segments
      segment = create_segment
      product = create_product(active: true, active_segment_ids: [segment.id])
      IndexAdminSearch.perform(product)

      assert_equal([], Alerts.new.missing_segments)

      segment.destroy!
      assert_equal([segment.id.to_s], Alerts.new.missing_segments)
    end
  end
end
