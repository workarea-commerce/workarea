require 'test_helper'
require 'workarea/lint'

module Workarea
  class Lint
    load_lints

    class InconsistentDetailsTest < TestCase
      def test_errors_for_each_product_with_inconsistent_details
        Catalog::Product.create!(
          name: 'Foo',
          variants: [{ sku: '123', details: { 'foo' => 'bar' } }]
        )

        Catalog::Product.create!(
          name: 'Bar',
          variants: [
            { sku: '456', details: { 'foo' => 'bar' } },
            { sku: '789', details: { 'baz' => 'asdf' } }
          ]
        )

        Catalog::Product.create!(
          name: 'Baz',
          variants: [
            { sku: '012', details: { 'foo' => 'bar' } },
            { sku: '345', details: { 'foo' => '' } }
          ]
        )

        Catalog::Product.create!(
          name: 'Qux',
          variants: [
            { sku: '678', details: { 'foo' => 'bar' } },
            { sku: '901' }
          ]
        )

        lint = InconsistentDetails.new
        lint.run

        assert_equal(4, lint.warnings)
      end
    end
  end
end
