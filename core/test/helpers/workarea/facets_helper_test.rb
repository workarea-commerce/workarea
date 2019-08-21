require 'test_helper'

module Workarea
  class FacetsHelperTest < ViewTest
    def test_facet_hidden_inputs
      facets = [Search::TermsFacet.new(stub_everything, 'color')]

      params[:color] = %w(Red Blue)
      assert_match(
        /input type="hidden".*name="color\[\]".*value="Red"/,
        facet_hidden_inputs(facets)
      )
      assert_match(
        /input type="hidden".*name="color\[\]".*value="Blue"/,
        facet_hidden_inputs(facets)
      )
    end

    def test_price_range_facet_text
      number = 99.99
      price = number_to_currency(number.to_m)
      over = price_range_facet_text(from: number)
      under = price_range_facet_text(to: number)
      range = price_range_facet_text(from: 1.99, to: 99.99)

      assert_equal(over, t('workarea.facets.price_range.over', price: price))
      assert_equal(under, t('workarea.facets.price_range.under', price: price))
      assert_equal(range, '$1.99 - $99.99')
    end
  end
end
