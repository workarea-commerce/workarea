require 'test_helper'

module Workarea
  module Metrics
    class SearchByDayTest < TestCase
      def test_save_search
        travel_to Time.zone.local(2018, 11, 26)

        SearchByDay.save_search('', 3)
        assert_equal(0, SearchByDay.count)

        SearchByDay.save_search('a', 3)
        assert_equal(0, SearchByDay.count)

        SearchByDay.save_search('a', '')
        assert_equal(0, SearchByDay.count)

        2.times do
          SearchByDay.save_search('Foo  Bar', '3')
          assert_equal(1, SearchByDay.count)
        end

        search = SearchByDay.first
        assert_equal('20181126-foo_bar', search.id)
        assert_equal('foo_bar', search.query_id)
        assert_equal('foo bar', search.query_string)
        assert_equal(3, search.total_results)
        assert_equal(2, search.searches)
      end

      def test_save_search_typecasting
        SearchByDay.save_search(:foo, '0')
        assert_equal(1, SearchByDay.count)

        search = SearchByDay.first.as_document
        assert_equal('foo', search['query_id'])
        assert_equal('foo', search['query_string'])
        assert_equal(0, search['total_results'])
        assert_equal(1, search['searches'])
      end
    end
  end
end
