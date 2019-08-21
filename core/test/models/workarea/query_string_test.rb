require 'test_helper'

module Workarea
  class QueryStringTest < TestCase
    def test_id
      query = QueryString.new('testing tests')
      assert_equal('test_test', query.id)

      query = QueryString.new('FOO BaR')
      assert_equal('foo_bar', query.id)

      query = QueryString.new('<script>alert("hello")<script>;')
      assert_equal('alert_hello', query.id)
    end

    def test_global_id
      tests = [
        'testing tests',
        'FOO BaR',
        '<script>alert("hello")<script>;',
        'wierd.query',
        '\\query',
        '4" tree',
        'tool set AND'
      ]

      tests.each do |string|
        query = QueryString.new(string)
        assert_equal(query.id, GlobalID.find(query.to_gid).id)
      end
    end

    def test_sanitized
      query = QueryString.new('<script>alert("hello")<script>;')
      refute_includes(query.sanitized, 'script')

      query = QueryString.new('<script>alert("hello")<script>;')
      refute_includes(query.sanitized, '(')
      refute_includes(query.sanitized, ')')

      query = QueryString.new('wierd.query')
      refute_includes(query.sanitized, '.')

      query = QueryString.new('\\query')
      refute_includes(query.sanitized, "\\")

      query = QueryString.new('/query')
      refute_includes(query.sanitized, '/')

      query = QueryString.new('{query}')
      refute_includes(query.sanitized, '{')
      refute_includes(query.sanitized, '}')

      query = QueryString.new('query!')
      refute_includes(query.sanitized, '!')

      query = QueryString.new('~query~')
      refute_includes(query.sanitized, '~')

      query = QueryString.new('query - - ')
      refute_includes(query.sanitized, ' - ')

      query = QueryString.new('test -')
      assert_equal('test', query.sanitized)

      query = QueryString.new('test - ')
      assert_equal('test', query.sanitized)

      query = QueryString.new('4" tree')
      assert_equal('4\" tree', query.sanitized)

      query = QueryString.new('"4 tree"')
      assert_equal('"4 tree"', query.sanitized)

      query_string = QueryString.new('tool set AND')
      assert_equal('tool set and', query_string.sanitized)

      query_string = QueryString.new('tool set OR')
      assert_equal('tool set or', query_string.sanitized)

      query_string = QueryString.new('tool set')
      assert_equal('tool set', query_string.sanitized)
    end

    def test_phrase
      assert(QueryString.new('tool set').phrase?)
      refute(QueryString.new('tool').phrase?)
    end
  end
end
