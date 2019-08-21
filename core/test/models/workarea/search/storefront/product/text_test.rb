require 'test_helper'

module Workarea
  module Search
    class Storefront
      class Product
        class TextTest < IntegrationTest
          def test_catalog_content
            product = create_product(
              browser_title: 'browser_title',
              meta_description: 'meta_description',
              description: 'description'
            )

            text = Product.new(product).catalog_content
            assert_includes(text, 'browser_title')
            assert_includes(text, 'meta_description')
            assert_includes(text, 'description')
          end

          def test_category_name
            product = create_product(name: 'Foo')
            create_category(name: 'First', product_ids: [product.id])
            create_category(name: 'Second', product_ids: [product.id])
            create_category(
              name: 'Third',
              product_rules: [
                { name: 'search', operator: 'equals', value: 'foo' }
              ]
            )

            text = Product.new(product).category_names

            assert_includes(text, 'First')
            assert_includes(text, 'Second')
            assert_includes(text, 'Third')
          end

          def test_details_content
            product = Catalog::Product.new(
              details: {
                'Color' => ['Red', 'Blue'],
                'Info' => {
                    'Material' => ['Cotton', 'Polyester']
                }
              },
              variants: [
                { details: { 'Size' => 'Small' } },
                { details: { 'Size' => 'Large' } }
              ]
            )

            text = Product.new(product).details_content

            assert_includes(text, 'Size')
            assert_includes(text, 'Small')
            assert_includes(text, 'Large')
            assert_includes(text, 'Color')
            assert_includes(text, 'Red')
            assert_includes(text, 'Blue')
            assert_includes(text, 'Material')
            assert_includes(text, 'Cotton')
            assert_includes(text, 'Polyester')
          end
        end
      end
    end
  end
end
