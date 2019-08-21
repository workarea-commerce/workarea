module Workarea
  module FeaturedProductsTest
    def test_adding_a_product
      featured_product_model.add_product('foo')
      assert_includes(featured_product_model.reload.product_ids, 'foo')
      assert(featured_product_model.featured_product?('foo'))

      featured_product_model.add_product('bar')
      assert_equal('bar', featured_product_model.reload.product_ids.first)
      assert(featured_product_model.featured_product?('bar'))
    end

    def test_removing_a_product
      featured_product_model.add_product('foo')
      featured_product_model.remove_product('foo')
      assert_empty(featured_product_model.reload.product_ids)
      refute(featured_product_model.featured_product?('foo'))
    end

    def test_cleaning_product_ids
      ['', nil].each do |blank|
        featured_product_model.add_product(blank)
        assert_equal(0, featured_product_model.reload.product_ids.length)
      end

      2.times { featured_product_model.add_product('foo') }
      assert_equal(['foo'], featured_product_model.reload.product_ids)
    end
  end
end
