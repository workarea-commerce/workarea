require 'test_helper'

module Workarea
  class Segment
    module Rules
      class LocationOptionTest < TestCase
        def test_search
          assert_equal([LocationOption['US-PA']], LocationOption.search('penn'))
          assert_equal([LocationOption['US-PA']], LocationOption.search('Penn'))
          assert_equal([LocationOption['CA']], LocationOption.search('cana'))
          assert_equal([LocationOption['CA']], LocationOption.search('CaNa'))
        end
      end
    end
  end
end
