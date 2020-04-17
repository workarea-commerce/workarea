require 'test_helper'

module Workarea
  class HashUpdateTest < TestCase
    def test_result
      original = { 'foo' => 'bar' }

      result = HashUpdate.new(original: original, adds: %w(key value)).result
      assert_equal(%w(value), result['key'])

      result = HashUpdate.new(original: original, updates: %w(foo baz)).result
      assert_equal(%w(baz), result['foo'])

      result = HashUpdate.new(original: original, removes: %w(foo)).result
      refute_includes(result.keys, 'foo')

      result = HashUpdate.new(original: original, adds: ['key', 'one, two ']).result
      assert_equal(%w(one two), result['key'])

      result = HashUpdate.new(original: original, updates: ['key', 'one,  two, three ']).result
      assert_equal(%w(one two three), result['key'])
    end
  end
end
