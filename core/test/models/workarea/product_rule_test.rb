require 'test_helper'

module Workarea
  class ProductRuleTest < TestCase
    def test_valid
      rule = ProductRule.new
      refute(rule.valid?)
      assert(rule.errors[:value].present?)
      assert(rule.errors[:name].present?)
    end

    def test_category
      rule = ProductRule.new
      refute(rule.category?)

      rule.name = 'category'
      assert(rule.category?)
    end

    def test_bool_values
      rule = ProductRule.new

      rule.value = 'true'
      assert(rule.true?)

      rule.value = 'TRUE'
      assert(rule.true?)

      rule.value = 'false'
      assert(rule.false?)

      rule.value = 'FALSE'
      assert(rule.false?)
    end

    def test_excluded_products
      rule = ProductRule.new
      refute(rule.product_exclusion?)

      rule.name = 'excluded_products'
      assert(rule.product_exclusion?)
    end

    def test_terms
      rule = ProductRule.new(value: 'foo')
      assert_equal(%w(foo), rule.terms)

      rule = ProductRule.new(value: 'foo,')
      assert_equal(%w(foo), rule.terms)

      rule = ProductRule.new(value: ', foo, bar')
      assert_equal(%w(foo bar), rule.terms)
    end
  end
end
