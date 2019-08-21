require 'test_helper'

module Workarea
  class HashUpdateTest < TestCase
    def test_apply
      hash = { 'foo' => 'bar' }

      HashUpdate.new(adds: %w(key value)).apply(hash)
      assert_equal(%w(value), hash['key'])

      HashUpdate.new(updates: %w(foo baz)).apply(hash)
      assert_equal(%w(baz), hash['foo'])

      HashUpdate.new(removes: %w(foo)).apply(hash)
      refute_includes(hash.keys, 'foo')

      HashUpdate.new(adds: ['key', 'one, two ']).apply(hash)
      assert_equal(%w(one two), hash['key'])

      HashUpdate.new(updates: ['key', 'one,  two, three ']).apply(hash)
      assert_equal(%w(one two three), hash['key'])
    end
  end
end
