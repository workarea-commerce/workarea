require 'test_helper'

module Workarea
  module Admin
    class TaxCategoriesIntegrationTest < Workarea::IntegrationTest
      include Admin::IntegrationTest

      setup :set_tax_category

      def set_tax_category
        @tax_category = {
            name: 'Tax Category',
            code: '001'
          }
      end

      def test_creates_a_new_tax_category
        post admin.tax_categories_path,
          params: { category: @tax_category }

        assert_equal(1, Tax::Category.count)

        category = Tax::Category.first
        assert_equal('Tax Category', category.name)
        assert_equal('001', category.code)
      end

      def test_updates_a_tax_category
        category = create_tax_category(name: "test tax")
        patch admin.tax_category_path(category),
          params: { category: { name: 'foo bar'} }

        assert_equal(1, Tax::Category.count)
        assert_equal('foo bar', Tax::Category.first.name)
      end

      def test_deletes_a_tax_category
        category = create_tax_category
        delete admin.tax_category_path(category)
        assert_equal(0, Tax::Category.count)
      end
    end
  end
end
