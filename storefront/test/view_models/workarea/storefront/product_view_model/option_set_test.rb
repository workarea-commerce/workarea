require 'test_helper'

module Workarea
  module Storefront
    class ProductViewModel
      class OptionSetTest < TestCase
        def test_from_sku
          product = create_product(
            variants: [
              {
                 sku: 'SKU1',
                 details: { color: 'Red', size: 'Large', material: 'Cotton' }
              },
              {
                 sku: 'SKU2',
                 details: { color: 'Red', size: 'Small', material: 'Cotton' }
              },
              {
                 sku: 'SKU3',
                 details: { color: 'Blue', size: 'Small', material: 'Suede' }
              }
            ]
          )

          set = OptionSet.from_sku(product, 'SKU2')
          assert_equal(3, set.currently_selected_options.size)
          assert_equal('Red', set.currently_selected_options['color'])
          assert_equal('Small', set.currently_selected_options['size'])
          assert_equal('Cotton', set.currently_selected_options['material'])

          set = OptionSet.from_sku(product, 'SKU3')
          assert_equal(3, set.currently_selected_options.size)
          assert_equal('Blue', set.currently_selected_options['color'])
          assert_equal('Small', set.currently_selected_options['size'])
          assert_equal('Suede', set.currently_selected_options['material'])
        end

        def test_all_options
          product = create_product(
            variants: [
              { sku: 'SKU1', details: {} },
              { sku: 'SKU2', details: {} },
              { sku: 'SKU3', details: {} }
            ]
          )

          set = OptionSet.new(product)
          assert_equal([], set.all_options)

          product = create_product(
            variants: [
              { sku: 'SKU1', details: {} },
              { sku: 'SKU2', details: { color: 'Red' } }
            ]
          )

          set = OptionSet.new(product)
          assert_equal(1, set.all_options.size)
          assert_includes(set.all_options, 'color')

          product = create_product(
            variants: [
              {
                 sku: 'SKU1',
                 details: { color: 'Red', size: 'Large', material: 'Cotton' }
              },
              {
                 sku: 'SKU2',
                 details: { color: 'Red', material: 'Cotton' }
              },
              {
                 sku: 'SKU3',
                 details: { color: 'Blue', size: 'Small', fit: 'Tight' }
              }
            ]
          )

          set = OptionSet.new(product)
          assert_equal(4, set.all_options.size)
          assert_includes(set.all_options, 'color')
          assert_includes(set.all_options, 'size')
          assert_includes(set.all_options, 'material')
          assert_includes(set.all_options, 'fit')
        end

        def test_currently_selected_options
          product = create_product(
            variants: [
              {
                 sku: 'SKU1',
                 details: { color: 'Red', size: 'Large', material: 'Cotton' }
              },
              {
                 sku: 'SKU2',
                 details: { color: 'Red', material: 'Cotton' }
              },
              {
                 sku: 'SKU3',
                 details: { color: 'Blue', size: 'Small', fit: 'Tight' }
              }
            ]
          )

          set = OptionSet.new(product)
          assert_equal({}, set.currently_selected_options)

          set = OptionSet.new(product, color: 'Blue')
          assert_equal({ 'color' => 'Blue' }, set.currently_selected_options)

          set = OptionSet.new(product, color: 'Red', material: 'Cotton')
          assert_equal(
            { 'color' => 'Red', 'material' => 'Cotton' },
            set.currently_selected_options
          )
        end

        def test_option_selects
          product = create_product(
            variants: [
              { sku: 'SKU1', details: {} },
              { sku: 'SKU2', details: {} },
              { sku: 'SKU3', details: {} }
            ]
          )

          set = OptionSet.new(product)
          assert_equal([], set.options_for_selection)

          product = create_product(
            variants: [
              { sku: 'SKU1', details: {} },
              { sku: 'SKU2', details: { color: 'Red' } }
            ]
          )

          set = OptionSet.new(product)
          assert_equal(1, set.options_for_selection.size)
          assert_equal('Color', set.options_for_selection.first.name)
          assert_equal('color', set.options_for_selection.first.slug)

          product = create_product(
            variants: [
              {
                 sku: 'SKU1',
                 details: { color: 'Red', size: 'Large', material: 'Cotton' }
              },
              {
                 sku: 'SKU2',
                 details: { color: 'Red', material: 'Cotton' }
              },
              {
                 sku: 'SKU3',
                 details: { color: 'Blue', size: 'Small', fit: 'Tight' }
              }
            ]
          )

          set = OptionSet.new(product)
          assert_equal(4, set.options_for_selection.size)
          slugs = set.options_for_selection.map(&:slug)
          assert_includes(slugs, 'color')
          assert_includes(slugs, 'size')
          assert_includes(slugs, 'material')
          assert_includes(slugs, 'fit')

          set = OptionSet.new(product, color: 'Red')
          assert_equal(3, set.options_for_selection.size)
          slugs = set.options_for_selection.map(&:slug)
          assert_includes(slugs, 'color')
          assert_includes(slugs, 'size')
          assert_includes(slugs, 'material')

          set = OptionSet.new(product, color: 'Blue')
          assert_equal(3, set.options_for_selection.size)
          slugs = set.options_for_selection.map(&:slug)
          assert_includes(slugs, 'color')
          assert_includes(slugs, 'size')
          assert_includes(slugs, 'fit')
        end

        def test_selections
          product = create_product(
            variants: [
              {
                 sku: 'SKU1',
                 details: { color: 'Red', size: 'Large', material: 'Cotton' }
              },
              {
                 sku: 'SKU2',
                 details: { color: 'Red', material: 'Cotton' }
              },
              {
                 sku: 'SKU3',
                 details: { color: 'Blue', size: 'Small', fit: 'Tight' }
              }
            ]
          )

          set = OptionSet.new(product)
          assert_equal(4, set.options_for_selection.size)

          color = set.options_for_selection.detect { |so| so.slug == 'color' }
          assert_equal(2, color.selections.size)
          assert_includes(color.selections, 'Red')
          assert_includes(color.selections, 'Blue')
          assert_nil(color.current)

          size = set.options_for_selection.detect { |so| so.slug == 'size' }
          assert_equal(2, size.selections.size)
          assert_includes(size.selections, 'Large')
          assert_includes(size.selections, 'Small')
          assert_nil(size.current)

          material = set.options_for_selection.detect { |so| so.slug == 'material' }
          assert_equal(1, material.selections.size)
          assert_includes(material.selections, 'Cotton')
          assert_nil(material.current)

          fit = set.options_for_selection.detect { |so| so.slug == 'fit' }
          assert_equal(1, fit.selections.size)
          assert_includes(fit.selections, 'Tight')
          assert_nil(fit.current)

          set = OptionSet.new(product, color: 'Red')
          assert_equal(3, set.options_for_selection.size)

          color = set.options_for_selection.detect { |so| so.slug == 'color' }
          assert_equal(2, color.selections.size)
          assert_includes(color.selections, 'Red')
          assert_includes(color.selections, 'Blue')
          assert_equal('Red', color.current)

          size = set.options_for_selection.detect { |so| so.slug == 'size' }
          assert_equal(1, size.selections.size)
          assert_includes(size.selections, 'Large')
          assert_nil(size.current)

          material = set.options_for_selection.detect { |so| so.slug == 'material' }
          assert_equal(1, material.selections.size)
          assert_includes(material.selections, 'Cotton')
          assert_nil(size.current)

          set = OptionSet.new(product, material: 'Cotton')
          assert_equal(3, set.options_for_selection.size)

          color = set.options_for_selection.detect { |so| so.slug == 'color' }
          assert_equal(1, color.selections.size)
          assert_includes(color.selections, 'Red')
          assert_nil(color.current)

          size = set.options_for_selection.detect { |so| so.slug == 'size' }
          assert_equal(1, size.selections.size)
          assert_includes(size.selections, 'Large')
          assert_nil(size.current)

          material = set.options_for_selection.detect { |so| so.slug == 'material' }
          assert_equal(1, material.selections.size)
          assert_includes(material.selections, 'Cotton')
          assert_equal('Cotton', material.current)
        end

        def test_current_variant
          product = create_product(
            variants: [
              {
                 sku: 'SKU1',
                 details: { color: 'Red', size: 'Large', material: 'Cotton' }
              },
              {
                 sku: 'SKU2',
                 details: { color: 'Red', size: 'Small', material: 'Cotton' }
              },
              {
                 sku: 'SKU3',
                 details: { color: 'Blue', size: 'Small', material: 'Suede' }
              }
            ]
          )

          set = OptionSet.new(product)
          assert_nil(set.current_variant)

          set = OptionSet.new(product, color: 'Red')
          assert_nil(set.current_variant)

          set = OptionSet.new(product, color: 'Red', size: 'Small')
          assert_nil(set.current_variant)

          set = OptionSet.new(product,
            color: 'Red',
            size: 'Small',
            material: 'Cotton'
          )
          assert_equal(
            product.variants.find_by(sku: 'SKU2'),
            set.current_variant
          )
        end

        def test_respecting_options_for_selection_sort
          product = create_product(
            variants: [
              {
                 sku: 'SKU1',
                 details: { color: 'Red', size: 'Large', material: 'Cotton' }
              },
              {
                 sku: 'SKU2',
                 details: { color: 'Red', size: 'Small', material: 'Cotton' }
              },
              {
                 sku: 'SKU3',
                 details: { color: 'Blue', size: 'Small', material: 'Suede' }
              }
            ]
          )

          Workarea.config.option_selections_sort = ->(p, o) { o.sort_by(&:name) }

          set = OptionSet.new(product)
          assert_equal(
            %w(color material size),
            set.options_for_selection.map(&:slug)
          )
        end

        def test_not_losing_formatting_with_titleize
          product = create_product(
            variants: [
              { sku: 'SKU1', details: { size: '1"' } },
              { sku: 'SKU2', details: { size: '2"' } },
              { sku: 'SKU3', details: { size: '3"' } }
            ]
          )

          set = OptionSet.new(product)
          size = set.options_for_selection.detect { |so| so.slug == 'size' }
          assert_equal(3, size.selections.size)
          assert_includes(size.selections, '1"')
          assert_includes(size.selections, '2"')
          assert_includes(size.selections, '3"')
        end

        def test_building_from_sku_with_missing_variant
          product = create_product(
            variants: [
              { sku: 'SKU1', details: { size: '1"' } },
              { sku: 'SKU2', details: { size: '2"' } },
              { sku: 'SKU3', details: { size: '3"' } }
            ]
          )

          set = OptionSet.from_sku(product, 'SKU4')
          assert_equal(1, set.options_for_selection.size)
        end

        def test_an_option_with_a_single_selection
          product = create_product(
            variants: [
              { sku: 'SKU1', details: { color: 'Red', size: 'Large' } },
              { sku: 'SKU2', details: { color: 'Red', size: 'Medium' } },
              { sku: 'SKU3', details: { color: 'Red', size: 'Small' } }
            ]
          )

          set = OptionSet.new(product)
          assert_equal(1, set.currently_selected_options.size)
          assert_equal('Red', set.currently_selected_options['color'])

          color = set.options_for_selection.detect { |so| so.slug == 'color' }
          assert_equal(1, color.selections.size)
          assert_includes(color.selections, 'Red')
          assert_equal('Red', color.current)
        end
      end
    end
  end
end
