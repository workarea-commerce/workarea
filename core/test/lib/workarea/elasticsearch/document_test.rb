require 'test_helper'

module Workarea
  module Elasticsearch
    class DocumentTest < TestCase
      Workarea.config.elasticsearch_mappings.foo = {
        properties: { id: { type: 'keyword' } }
      }

      class Foo
        include Elasticsearch::Document

        def id
          model[:id]
        end

        def as_document
          { id: id, count: 1 }
        end
      end

      class Foo
        class Bar < Foo
        end
      end

      setup :setup_indexes

      def setup_indexes
        Foo.reset_indexes!
      end

      def test_type
        assert_equal(:foo, Foo.type)
        assert_equal(:foo, Foo::Bar.type)
      end

      def test_current_index_prefix
        result = Elasticsearch::Document.current_index_prefix

        assert_includes(result, Rails.env)
        assert_includes(result, I18n.locale.to_s)
        assert_includes(result, Workarea.config.site_name.optionize)
      end

      def test_save
        Foo.save(id: '1')

        assert(1, Foo.count)
        results = Foo
                    .current_index
                    .search({ query: { match_all: {} } })
                    .dig('hits', 'hits')

        assert_equal({ 'id' => '1' }, results.first['_source'])
      end

      def test_bulk
        Foo.bulk([{ id: '1', bulk_action: 'index' }])

        assert(1, Foo.count)
        results = Foo
                    .current_index
                    .search({ query: { match_all: {} } })
                    .dig('hits', 'hits')

        assert_equal({ 'id' => '1' }, results.first['_source'])
      end

      def test_bulk_with_block
        set_locales(available: [:en, :es], default: :en, current: :en)
        Foo.bulk { { id: I18n.locale.to_s, bulk_action: 'index' } }

        find_results = -> do
          Foo
            .current_index
            .search({ query: { match_all: {} } })
            .dig('hits', 'hits')
        end

        I18n.locale = :en
        assert(1, Foo.count)
        assert_equal({ 'id' => 'en' }, find_results.call.first['_source'])

        I18n.locale = :es
        assert(1, Foo.count)
        assert_equal({ 'id' => 'es' }, find_results.call.first['_source'])
      end

      def test_update
        Foo.save(id: '1')
        Foo.update(id: '1', foo: 'bar')

        assert(1, Foo.count)
        results = Foo
                    .current_index
                    .search({ query: { match_all: {} } })
                    .dig('hits', 'hits')

        assert_equal({ 'id' => '1', 'foo' => 'bar' }, results.first['_source'])
      end

      def test_delete
        Foo.save(id: '1')
        Foo.delete('1')
        assert(0, Foo.count)
      end

      def test_count
        Foo.save(id: '1')

        assert_equal(1, Foo.count)
        assert_equal(1, Foo.current_index.count({}))

        # Test count with query filter
        assert_equal(1, Foo.current_index.count({ query: { term: { id: '1' } } }))
        assert_equal(0, Foo.current_index.count({ query: { term: { id: '999' } } }))
      end

      def test_search
        Foo.save(id: '1')
        Foo.save(id: '2')

        results = Foo.search(query: { term: { id: '1' } }).dig('hits', 'hits')
        assert_equal({ 'id' => '1' }, results.first['_source'])
      end

      def test_scroll
        5.times { |i| Foo.save(id: i.to_s) }

        results = Foo.search({ size: 2 }, scroll: '1m')
        assert(results['_scroll_id'].present?)
        assert_equal(2, results['hits']['hits'].size)

        results = Foo.scroll(results['_scroll_id'], scroll: '1m')
        assert(results['_scroll_id'].present?)
        assert_equal(2, results['hits']['hits'].size)

        results = Foo.scroll(results['_scroll_id'])
        assert(results['_scroll_id'].present?)
        assert_equal(1, results['hits']['hits'].size)

      ensure
        Foo.clear_scroll(results['_scroll_id'])
      end

      # Regression: Index#create! must be idempotent.
      #
      # The old implementation used `unless exists?` before calling
      # `indices.create`.  This introduced a TOCTOU race: between the `exists?`
      # check and the actual `create` call another request could have created
      # (or re-created) the same index, causing a
      # `resource_already_exists_exception` (HTTP 400).  When that exception
      # propagated the index was left in a deleted state (because `delete!` had
      # already run), which then caused `index_not_found_exception` (404) for
      # any search performed by the same test.
      #
      # The fix removes the guard and rescues the 400 BadRequest instead, making
      # the operation atomic.
      def test_create_idempotent_when_index_already_exists
        index = Foo.current_index

        # First call – index exists from setup_indexes; should not raise.
        assert_nothing_raised { index.create! }
      end

      def test_create_force_recreates_index_and_remains_searchable
        Foo.save(id: 'before')
        Foo.current_index.wait_for_health

        # force: true must delete-and-recreate; previously saved documents are gone
        Foo.reset_indexes!

        assert_equal(0, Foo.count, 'expected empty index after force-recreate')

        Foo.save(id: 'after')
        assert_equal(1, Foo.count, 'expected new document after force-recreate')
      end

      def test_create_force_idempotent_called_twice
        # Calling reset_indexes! back-to-back must not raise
        # resource_already_exists_exception on the second call.
        assert_nothing_raised do
          Foo.reset_indexes!
          Foo.reset_indexes!
        end
      end
    end
  end
end
