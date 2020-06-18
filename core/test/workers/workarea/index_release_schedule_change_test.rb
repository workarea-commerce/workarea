require 'test_helper'

module Workarea
  class IndexReleaseScheduleChangeTest < TestCase
    include TestCase::SearchIndexing

    setup :set_product

    def set_product
      @product = create_product(name: 'Foo')
    end

    def test_reschedule
      a = create_release(name: 'A', publish_at: 1.week.from_now)
      b = create_release(name: 'B', publish_at: 2.weeks.from_now)
      c = create_release(name: 'C', publish_at: 4.weeks.from_now)

      b.as_current { @product.update!(name: 'Bar') }
      IndexProduct.perform(@product)

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }

      # Changing publish_at via `update` causes the release to publish due to Sidekiq inline
      previous_publish_at = b.publish_at
      b.set(publish_at: 5.weeks.from_now)

      Sidekiq::Callbacks.enable(IndexProduct) do
        IndexReleaseScheduleChange.new.perform(b.id, previous_publish_at, b.publish_at)
      end

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
    end

    def test_removing_from_schedule
      a = create_release(name: 'A', publish_at: 1.week.from_now)
      b = create_release(name: 'B', publish_at: 2.weeks.from_now)
      c = create_release(name: 'C', publish_at: 4.weeks.from_now)

      b.as_current { @product.update!(name: 'Bar') }
      IndexProduct.perform(@product)

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }

      # Changing publish_at via `update` causes the release to publish due to Sidekiq inline
      previous_publish_at = b.publish_at
      b.set(publish_at: nil)

      Sidekiq::Callbacks.enable(IndexProduct) do
        IndexReleaseScheduleChange.new.perform(b.id, previous_publish_at, nil)
      end

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
    end

    def test_adding_to_schedule
      a = create_release(name: 'A', publish_at: 1.week.from_now)
      b = create_release(name: 'B')
      c = create_release(name: 'C', publish_at: 4.weeks.from_now)

      b.as_current { @product.update!(name: 'Bar') }
      IndexProduct.perform(@product)

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }

      # Changing publish_at via `update` causes the release to publish due to Sidekiq inline
      b.set(publish_at: 2.weeks.from_now)

      Sidekiq::Callbacks.enable(IndexProduct) do
        IndexReleaseScheduleChange.new.perform(b.id, nil, b.publish_at)
      end

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
    end

    def test_destroyed
      a = create_release(name: 'A', publish_at: 1.week.from_now)
      b = create_release(name: 'B', publish_at: 2.weeks.from_now)
      c = create_release(name: 'C', publish_at: 4.weeks.from_now)

      b.as_current { @product.update!(name: 'Bar') }
      IndexProduct.perform(@product)

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      b.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_equal([@product], Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }

      Sidekiq::Callbacks.enable(IndexReleaseScheduleChange, IndexProduct) do
        b.destroy
      end

      a.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
      c.as_current { assert_empty(Search::ProductSearch.new(q: 'bar').results.pluck(:model)) }
    end
  end
end
