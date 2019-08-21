require 'test_helper'
require 'workarea/lint'

module Workarea
  class Lint
    load_lints

    class ProductsMissingVariantsTest < TestCase
      def test_warns_for_each_product_missing_variants
        3.times { create_product(variants: []) }
        lint = ProductsMissingVariants.new
        lint.run

        assert_equal(3, lint.errors)
      end
    end
  end
end
