require 'test_helper'

module Workarea
  module Search
    class ProductRulesTest < TestCase
      def test_equality_rules
        rule = ProductRule.new(name: 'color', operator: 'equals', value: 'red')

        assert_equal(
          [{ terms: { 'facets.color' => ['red'] } }],
          ProductRules.new([rule]).to_a
        )

        rule = ProductRule.new(
          name: 'on_sale',
          operator: 'equals',
          value: 'true'
        )

        assert_equal(
          [{ term: { 'facets.on_sale' => true } }],
          ProductRules.new([rule]).to_a
        )
      end

      def test_inequality_rules
        rule = ProductRule.new(
          name: 'color',
          operator: 'not_equal',
          value: 'red'
        )

        assert_equal(
          [{ bool: { must_not: [{ terms: { 'facets.color' => ['red'] } }] } }],
          ProductRules.new([rule]).to_a
        )

        rule = ProductRule.new(
          name: 'on_sale',
          operator: 'not_equal',
          value: 'true'
        )

        assert_equal(
          [{ bool: { must_not: [{ term: { 'facets.on_sale' => true } }] } }],
          ProductRules.new([rule]).to_a
        )
      end

      def test_greater_than_rules
        rule = ProductRule.new(
          name: 'price',
          operator: 'greater_than',
          value: '10'
        )

        assert_equal(
          [{ range: { 'numeric.price' => { gt: '10' } } }],
          ProductRules.new([rule]).to_a
        )

        rule = ProductRule.new(
          name: 'price',
          operator: 'greater_than_or_equal',
          value: '10'
        )

        assert_equal(
          [{ range: { 'numeric.price' => { gte: '10' } } }],
          ProductRules.new([rule]).to_a
        )
      end

      def test_less_than_rules
        rule = ProductRule.new(
          name: 'price',
          operator: 'less_than',
          value: '10'
        )

        assert_equal(
          [{ range: { 'numeric.price' => { lt: '10' } } }],
          ProductRules.new([rule]).to_a
        )

        rule = ProductRule.new(
          name: 'price',
          operator: 'less_than_or_equal',
          value: '10'
        )

        assert_equal(
          [{ range: { 'numeric.price' => { lte: '10' } } }],
          ProductRules.new([rule]).to_a
        )
      end

      def test_search_rules
        rule = ProductRule.new(
          name: 'search',
          operator: 'equals',
          value: 'foo bar'
        )

        assert_equal(
          [{ query_string: { query: 'foo bar' } }],
          ProductRules.new([rule]).to_a
        )
      end

      def test_rules_with_dates
        date = Time.zone.parse('2013/8/25')
        rule = ProductRule.new(
          name: 'created_at',
          operator: 'less_than',
          value: "#{date.year}/#{date.month}/#{date.day}"
        )

        assert_equal(
          [{ range: { 'created_at' => { lt: date } } }],
          ProductRules.new([rule]).to_a
        )
      end

      def test_category_rules
        category_one = create_category(
          product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
        )

        category_two = create_category(
          product_rules: [
            { name: 'search', operator: 'equals', value: 'bar' },
            { name: 'category', operator: 'equals', value: category_one.id }
          ]
        )

        assert_equal(
          [
            { query_string: { query: 'bar' } },
            {
              bool: {
                should: [
                  {
                    bool: {
                      should: [
                        { term: { 'facets.category_id' => category_one.id.to_s } },
                        { bool: { must: [{ query_string: { query: 'foo' } }] } }
                      ]
                    }
                  }
                ]
              }
            }
          ],
          ProductRules.new(category_two.product_rules).to_a
        )

        category_ids = [category_one, category_two].map(&:id).join(',')
        category_three = create_category(
          product_rules: [
            { name: 'search', operator: 'equals', value: 'baz' },
            { name: 'category', operator: 'equals', value: category_ids }
          ]
        )

        assert_equal(
          [
            {
              query_string: { query: "baz" }
            },
            {
              bool: {
                should: [
                  {
                    bool: {
                      should: [
                        {
                          term: {"facets.category_id" => category_one.id.to_s}
                        },
                        {
                          bool: {
                            must: [
                              {query_string: {query: "foo"}}
                            ]
                          }
                        }
                      ]
                    }
                  }, {
                    bool: {
                      should: [
                        {
                          term: {"facets.category_id" => category_two.id.to_s}
                        },
                        {
                          bool: {
                            must: [
                              {
                                query_string: {
                                  query: "bar"
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ],
          ProductRules.new(category_three.product_rules).to_a
        )
      end

      def test_category_reference_loop
        category_one = create_category(
          product_rules: [{ name: 'search', operator: 'equals', value: 'foo' }]
        )

        category_two = create_category(
          product_rules: [
            { name: 'search', operator: 'equals', value: 'bar' },
            { name: 'category', operator: 'equals', value: category_one.id }
          ]
        )

        category_one.product_rules.create!(
          name: 'category',
          operator: 'equals',
          value: category_two.id
        )

        assert_equal(
          [
            {
              query_string: {
                query: "bar"
              }
            },
            {
              bool: {
                should: [
                  {
                    bool: {
                      should: [
                        {
                          term: {
                            "facets.category_id" => category_one.id.to_s
                          }
                        },
                        {
                          bool: {
                            must: [
                              {
                                query_string: { query: "foo" }
                              },
                              {
                                bool: {
                                  should: [
                                    {
                                      bool: {
                                        should: [
                                          {
                                            term: {
                                              "facets.category_id" => category_two.id.to_s
                                            }
                                          },
                                          {
                                            bool: {
                                              must: [
                                                { query_string: { query: "bar" } }
                                              ]
                                            }
                                          }
                                        ]
                                      }
                                    }
                                  ]
                                }
                              }
                            ]
                          }
                        }
                      ]
                    }
                  }
                ]
              }
            }
          ],
          ProductRules.new(category_two.product_rules).to_a
        )
      end

      def test_terms_rules
        rule = ProductRule.new(
          name: 'color',
          operator: 'equals',
          value: 'Red'
        )

        assert_equal(
          [{ terms: { 'facets.color' => %w(Red) } }],
          ProductRules.new([rule]).to_a
        )

        rule = ProductRule.new(
          name: 'color',
          operator: 'equals',
          value: 'Red, Green'
        )

        assert_equal(
          [{ terms: { 'facets.color' => %w(Red Green) } }],
          ProductRules.new([rule]).to_a
        )
      end

      def test_excluded_products_rules
        rule = ProductRule.new(
          name: 'excluded_products',
          operator: 'equals',
          value: ', 1'
        )

        assert(rule.product_exclusion?)
        assert_equal(
          [{ bool: { must_not: { terms: { 'keywords.catalog_id' => ['1'] } } } }],
          ProductRules.new([rule]).to_a
        )

        rule = ProductRule.new(
          name: 'excluded_products',
          operator: 'equals',
          value: '1, 2'
        )

        assert(rule.product_exclusion?)
        assert_equal(
          [{ bool: { must_not: { terms: { 'keywords.catalog_id' => ['1', '2'] } } } }],
          ProductRules.new([rule]).to_a
        )
      end
    end
  end
end
