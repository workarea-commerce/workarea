require 'test_helper'

module Workarea
  class CountryTest < TestCase
    def test_country_searching
      assert_equal(Country['US'], Country.search_for('US'))
      assert_equal(Country['US'], Country.search_for('Us'))
      assert_equal(Country['US'], Country.search_for('USA'))
      assert_equal(Country['US'], Country.search_for('UsA'))
      assert_equal(Country['US'], Country.search_for('United States of America'))
      assert_equal(Country['US'], Country.search_for('united states of america'))
      assert_equal(Country['US'], Country.search_for(Country['US']))
      assert_equal(Country['US'], Country.search_for('United States'))
      assert_equal(Country['US'], Country.search_for('united states'))
      assert_equal(Country['US'], Country.search_for('United states'))
      assert_equal(Country['US'], Country.search_for('アメリカ合衆国'))
    end

    def test_country_json_serialization_isnt_insanely_verbose
      assert_equal('US', Country['US'].as_json)
    end
  end
end
