require 'test_helper'

module Workarea
  class Segment
    module Rules
      class GeolocationOptionTest < TestCase
        def test_search
          assert_equal([GeolocationOption['US-PA']], GeolocationOption.search('penn'))
          assert_equal([GeolocationOption['US-PA']], GeolocationOption.search('Penn'))
          assert_equal([GeolocationOption['CA']], GeolocationOption.search('cana'))
          assert_equal([GeolocationOption['CA']], GeolocationOption.search('CaNa'))
        end
      end
    end
  end
end
