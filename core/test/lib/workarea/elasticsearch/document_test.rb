require 'test_helper'

module Workarea
  module Elasticsearch
    class DocumentTest < TestCase
      Workarea.config.elasticsearch_mappings.foo = {
        foo: { properties: { id: { type: 'keyword' } } }
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
                    .search({ query: { match_all: {} } }, type: 'foo')
                    .dig('hits', 'hits')

        assert_equal({ 'id' => '1' }, results.first['_source'])
      end

      def test_bulk
        Foo.bulk([{ id: '1', bulk_action: 'index' }])

        assert(1, Foo.count)
        results = Foo
                    .current_index
                    .search({ query: { match_all: {} } }, type: 'foo')
                    .dig('hits', 'hits')

        assert_equal({ 'id' => '1' }, results.first['_source'])
      end

      def test_bulk_with_block
        set_locales(available: [:en, :es], default: :en, current: :en)
        Foo.bulk { { id: I18n.locale.to_s, bulk_action: 'index' } }

        find_results = -> do
          Foo
            .current_index
            .search({ query: { match_all: {} } }, type: 'foo')
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
                    .search({ query: { match_all: {} } }, type: 'foo')
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
        assert_equal(1, Foo.current_index.count({}, type: 'foo'))
        assert_equal(0, Foo.current_index.count({}, type: 'bar'))
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
    end
  end
end
