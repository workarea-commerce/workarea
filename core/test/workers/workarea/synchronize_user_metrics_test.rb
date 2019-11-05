require 'test_helper'

module Workarea
  class SynchronizeUserMetricsTest < IntegrationTest
    def test_enqueuing
      Sidekiq::Testing.fake!
      SynchronizeUserMetrics.async

      assert_difference -> { SynchronizeUserMetrics.jobs.size }, 1 do
        create_user
      end

      assert_difference -> { SynchronizeUserMetrics.jobs.size }, 2 do
        user = create_user
        user.update!(tags: %w(foo bar))
      end

      assert_difference -> { SynchronizeUserMetrics.jobs.size }, 2 do
        user = create_user
        user.update!(admin: true)
      end

      assert_difference -> { SynchronizeUserMetrics.jobs.size }, 1 do
        create_user.update!(password: 's0m3th1ng_3ls3!')
      end
    end

    def test_perform
      user = create_user(tags: %w(foo bar))

      assert_equal(1, Metrics::User.count)
      metrics = Metrics::User.first
      assert_equal(user.email, metrics.id)
      assert_equal(user.tags, metrics.tags)

      user.update!(tags: %w(bar baz))
      assert_equal(1, Metrics::User.count)
      assert_equal(%w(bar baz), metrics.reload.tags)

      user.update!(admin: true)
      assert_equal(1, Metrics::User.count)
      assert(metrics.reload.admin?)

      user.update!(admin: false)
      assert_equal(1, Metrics::User.count)
      refute(metrics.reload.admin?)

      user.update!(super_admin: true)
      assert_equal(1, Metrics::User.count)
      assert(metrics.reload.admin?)

      user.update!(super_admin: false)
      assert_equal(1, Metrics::User.count)
      refute(metrics.reload.admin?)
    end
  end
end
