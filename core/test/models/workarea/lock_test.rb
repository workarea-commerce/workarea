require 'test_helper'

module Workarea
  class LockTest < TestCase
    teardown :unlock

    def unlock
      Lock.destroy!('lock_test', 'foo')
    end

    def test_find
      Lock.create!('lock_test', 'foo')

      assert_equal('foo', Lock.find('lock_test'))
      assert_nil(Lock.find('lock_test_two'))

      unlock
      assert_nil(Lock.find('lock_test'))
    end

    def test_exists?
      Lock.create!('lock_test', 'foo')

      assert(Lock.exists?('lock_test'))
      refute(Lock.exists?('lock_test_two'))
    end

    def test_create!
      assert(Lock.create!('lock_test', 'foo'))
      assert_raises(Lock::Locked) { Lock.create!('lock_test', 'bar') }
      assert(Lock.create!('lock_test', 'foo', nx: false))
    end

    def test_destroy!
      Lock.create!('lock_test', 'foo')

      assert(Lock.destroy!('lock_test', 'bar'))
      assert(Lock.destroy!('lock_test', 'foo'))

      Lock.create!('lock_test', 'foo', ex: 1)
      sleep 2 # wait for lock to expire

      refute(Lock.exists?('lock_test'))
      assert(Lock.destroy!('lock_test', 'foo'))
    end
  end
end
