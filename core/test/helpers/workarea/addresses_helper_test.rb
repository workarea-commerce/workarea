require 'test_helper'

module Workarea
  class AddressesHelperTest < ViewTest
    setup :set_config
    teardown :reset_config

    def set_config
      @current_countries = Workarea.config.countries
      Workarea.config.countries = [Country['US'], Country['CA']]
    end

    def reset_config
      Workarea.config.countries = @current_countries
    end

    def test_country_options
      assert_equal(
        [['United States of America', 'US'], ['Canada', 'CA']],
        country_options
      )
    end

    def test_region_options
      regions = region_options.first.last
      nb = regions.find_index { |name, id| name == 'Nebraska' }
      nd = regions.find_index { |name, id| name == 'North Dakota' }

      assert_includes(regions, ['Pennsylvania', 'PA'])
      refute_nil(nb)
      refute_nil(nd)
      assert_operator(nb, :<, nd)
    end

    def test_region_options_with_nonexistent_names
      Workarea.config.countries = [Country['GB']]
      regions = region_options.first.last

      assert_includes(regions, ['Armagh, Banbridge and Craigavon', 'ABC'])
    end
  end
end
