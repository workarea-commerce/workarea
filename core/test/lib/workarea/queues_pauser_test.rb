require 'test_helper'

module Workarea
  class QueuesPauserTest < TestCase
    setup do
      # Override queues to a known small set for testing
      @original_queues_method = QueuesPauser.method(:queues)
      QueuesPauser.stubs(:queues).returns(%w[high default low])
    end

    # ---------------------------------------------------------------------------
    # pause_queues! — throttled 0.x path (Sidekiq::Throttled::QueuesPauser present)
    # ---------------------------------------------------------------------------

    def test_pause_queues_uses_throttled_pauser_when_defined
      pauser_instance = mock('throttled_pauser')
      pauser_instance.expects(:pause!).with('high')
      pauser_instance.expects(:pause!).with('default')
      pauser_instance.expects(:pause!).with('low')

      throttled_pauser_class = mock('throttled_pauser_class')
      throttled_pauser_class.stubs(:instance).returns(pauser_instance)

      # Inject the constant so the `if defined?` branch is taken
      sidekiq_throttled = Module.new
      sidekiq_throttled.const_set(:QueuesPauser, throttled_pauser_class)
      ::Sidekiq.const_set(:Throttled, sidekiq_throttled) unless ::Sidekiq.const_defined?(:Throttled)
      original_pauser = ::Sidekiq::Throttled.const_defined?(:QueuesPauser) &&
                        ::Sidekiq::Throttled.const_get(:QueuesPauser)

      ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser) if ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
      ::Sidekiq::Throttled.const_set(:QueuesPauser, throttled_pauser_class)

      QueuesPauser.pause_queues!
    ensure
      if ::Sidekiq.const_defined?(:Throttled) && ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
        ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser)
      end
    end

    # ---------------------------------------------------------------------------
    # pause_queues! — OSS / throttled 1.x fallback path
    # ---------------------------------------------------------------------------

    def test_pause_queues_calls_pause_on_queue_when_available
      # Ensure Sidekiq::Throttled::QueuesPauser is NOT defined for this test
      had_throttled_pauser = ::Sidekiq.const_defined?(:Throttled) &&
                             ::Sidekiq::Throttled.const_defined?(:QueuesPauser)

      queue_mock = mock('sidekiq_queue')
      queue_mock.stubs(:respond_to?).with(:pause!).returns(true)
      queue_mock.expects(:pause!).times(3)

      ::Sidekiq::Queue.stubs(:new).returns(queue_mock)

      # Remove the throttled pauser constant if present
      if ::Sidekiq.const_defined?(:Throttled) && ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
        ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser)
      end

      QueuesPauser.pause_queues!
    end

    def test_pause_queues_does_not_crash_when_pause_unavailable
      had_pauser = ::Sidekiq.const_defined?(:Throttled) &&
                   ::Sidekiq::Throttled.const_defined?(:QueuesPauser)

      queue_mock = mock('sidekiq_queue')
      queue_mock.stubs(:respond_to?).with(:pause!).returns(false)
      queue_mock.expects(:pause!).never

      ::Sidekiq::Queue.stubs(:new).returns(queue_mock)

      if ::Sidekiq.const_defined?(:Throttled) && ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
        ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser)
      end

      assert_nothing_raised { QueuesPauser.pause_queues! }
    end

    # ---------------------------------------------------------------------------
    # resume_queues! — throttled 0.x path
    # ---------------------------------------------------------------------------

    def test_resume_queues_uses_throttled_pauser_when_defined
      pauser_instance = mock('throttled_pauser')
      pauser_instance.expects(:resume!).with('high')
      pauser_instance.expects(:resume!).with('default')
      pauser_instance.expects(:resume!).with('low')

      throttled_pauser_class = mock('throttled_pauser_class')
      throttled_pauser_class.stubs(:instance).returns(pauser_instance)

      ::Sidekiq.const_set(:Throttled, Module.new) unless ::Sidekiq.const_defined?(:Throttled)
      ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser) if ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
      ::Sidekiq::Throttled.const_set(:QueuesPauser, throttled_pauser_class)

      QueuesPauser.resume_queues!
    ensure
      if ::Sidekiq.const_defined?(:Throttled) && ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
        ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser)
      end
    end

    # ---------------------------------------------------------------------------
    # resume_queues! — OSS / throttled 1.x fallback path
    # ---------------------------------------------------------------------------

    def test_resume_queues_calls_unpause_on_queue_when_available
      if ::Sidekiq.const_defined?(:Throttled) && ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
        ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser)
      end

      queue_mock = mock('sidekiq_queue')
      queue_mock.stubs(:respond_to?).with(:unpause!).returns(true)
      queue_mock.expects(:unpause!).times(3)

      ::Sidekiq::Queue.stubs(:new).returns(queue_mock)

      QueuesPauser.resume_queues!
    end

    def test_resume_queues_does_not_crash_when_unpause_unavailable
      if ::Sidekiq.const_defined?(:Throttled) && ::Sidekiq::Throttled.const_defined?(:QueuesPauser)
        ::Sidekiq::Throttled.send(:remove_const, :QueuesPauser)
      end

      queue_mock = mock('sidekiq_queue')
      queue_mock.stubs(:respond_to?).with(:unpause!).returns(false)
      queue_mock.expects(:unpause!).never

      ::Sidekiq::Queue.stubs(:new).returns(queue_mock)

      assert_nothing_raised { QueuesPauser.resume_queues! }
    end

    # ---------------------------------------------------------------------------
    # with_paused_queues
    # ---------------------------------------------------------------------------

    def test_with_paused_queues_resumes_after_block
      QueuesPauser.expects(:pause_queues!).once
      QueuesPauser.expects(:resume_queues!).once

      QueuesPauser.with_paused_queues { :work }
    end

    def test_with_paused_queues_resumes_even_if_block_raises
      QueuesPauser.expects(:pause_queues!).once
      QueuesPauser.expects(:resume_queues!).once

      assert_raises(RuntimeError) do
        QueuesPauser.with_paused_queues { raise 'boom' }
      end
    end
  end
end
