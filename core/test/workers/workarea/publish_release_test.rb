require 'test_helper'

module Workarea
  class PublishReleaseTest < TestCase
    include TestCase::SearchIndexing

    def test_publishes_the_release
      release = create_release
      PublishRelease.new.perform(release.id)
      release.reload
      assert(release.published?)
    end

    def test_tracks_the_changes_in_the_audit_log
      release = create_release
      PublishRelease.new.perform(release.id)

      assert_equal(1, Mongoid::AuditLog::Entry.count)
      assert(Mongoid::AuditLog::Entry.first.modifier.system?)
    end

    def test_reindexes_release_schedule
      product = create_product(name: 'Foo')

      a = create_release(publish_at: 1.week.from_now)
      b = create_release(publish_at: 2.weeks.from_now)
      c = create_release(publish_at: 4.weeks.from_now)

      b.as_current { product.update!(name: 'Bar') }
      IndexProduct.perform(product)

      assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model))
      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_equal([product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }

      Sidekiq::Callbacks.enable(IndexProduct) { PublishRelease.new.perform(b.id) }

      assert_equal([product], Search::ProductSearch.new(q: 'bar').results.pluck(:model))
      a.as_current { assert_equal([product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_equal([product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
    end
  end
end
