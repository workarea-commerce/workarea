require 'test_helper'

module Workarea
  class LockableTest < TestCase
    class Foo
      include Lockable

      def id
        '123'
      end
    end

    setup :foo
    teardown :unlock_foo

    def foo
      @foo ||= Foo.new
    end

    def unlock_foo
      foo.unlock!
    end

    def test_lock_key
      assert_equal('workarea/lockable_test/foo/123/lock', Foo.new.lock_key)
    end

    def test_default_lock_value
      assert_equal(foo.default_lock_value, foo.default_lock_value)
      refute_equal(Foo.new.default_lock_value, foo.default_lock_value)
    end

    def test_locked?
      refute(foo.locked?)

      foo.lock!
      assert(foo.locked?)
    end

    def test_lock!
      assert(foo.lock!)
      assert_raises(Lock::Locked) { foo.lock! }
      assert_raises(Lock::Locked) { Foo.new.lock! }

      foo.unlock!

      foo.lock!(value: 'bar')
      assert_equal('bar', Lock.find(foo.lock_key))

      foo.unlock!(value: 'bar')

      foo.lock!(ex: 1)
      sleep 2 # wait for lock to expire

      refute(foo.locked?)
      assert(foo.lock!)
    end

    def test_unlock!
      assert(foo.unlock!)

      foo.lock!
      assert(foo.unlock!)
      refute(foo.locked?)

      foo.lock!(value: 'bar')
      assert(foo.unlock!)
      assert(foo.locked?)
      assert(foo.unlock!(value: 'bar'))
      refute(foo.locked?)
    end
  end
end
