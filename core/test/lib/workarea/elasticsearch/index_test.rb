require 'test_helper'

module Workarea
  module Elasticsearch
    class IndexTest < TestCase
      class FakeIndices
        attr_reader :create_calls

        def initialize(errors = [])
          @errors = errors
          @create_calls = []
        end

        def create(params)
          @create_calls << params
          error = @errors.shift
          raise(error) if error.present?
        end
      end

      class FakeClient
        attr_reader :indices

        def initialize(indices)
          @indices = indices
        end
      end

      def test_create_retries_with_typed_mappings_when_es5_cast_error_is_raised
        cast_error = ::Elasticsearch::Transport::Transport::Errors::BadRequest.new(
          '[400] {"error":{"type":"class_cast_exception","reason":"java.util.ArrayList cannot be cast to java.util.Map"}}'
        )

        indices = FakeIndices.new([cast_error])
        client = FakeClient.new(indices)
        mappings = { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] }
        index = Index.new('test-index', mappings)
        index.stubs(:create_mappings_payload).returns(mappings)

        # Wrap hash in braces to pass as positional arg; Ruby 3.0+ no longer
        # coerces keyword args to positional for Struct#initialize.
        fake_settings = Struct.new(:elasticsearch_settings).new({ number_of_shards: 1 })
        Search::Settings.stubs(:current).returns(fake_settings)

        Workarea.stubs(:elasticsearch).returns(client)
        index.create!

        assert_equal(2, indices.create_calls.size)
        assert_equal(
          { _doc: { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] } },
          indices.create_calls.last.dig(:body, :mappings)
        )
      end

      def test_create_retries_with_typed_mappings_when_es5_cast_error_is_500
        cast_error = ::Elasticsearch::Transport::Transport::Errors::InternalServerError.new(
          '[500] {"error":{"type":"class_cast_exception","reason":"java.util.ArrayList cannot be cast to java.util.Map"}}'
        )

        indices = FakeIndices.new([cast_error])
        client = FakeClient.new(indices)
        mappings = { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] }
        index = Index.new('test-index', mappings)
        index.stubs(:create_mappings_payload).returns(mappings)

        fake_settings = Struct.new(:elasticsearch_settings).new({ number_of_shards: 1 })
        Search::Settings.stubs(:current).returns(fake_settings)

        Workarea.stubs(:elasticsearch).returns(client)
        index.create!

        assert_equal(2, indices.create_calls.size)
        assert_equal(
          { _doc: { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] } },
          indices.create_calls.last.dig(:body, :mappings)
        )
      end

      def test_create_retries_with_backoff_using_same_payload_before_fallback
        cast_error = ::Elasticsearch::Transport::Transport::Errors::InternalServerError.new(
          '[500] {"error":{"type":"class_cast_exception","reason":"java.util.ArrayList cannot be cast to java.util.Map"}}'
        )

        indices = FakeIndices.new([cast_error, cast_error])
        client = FakeClient.new(indices)
        mappings = { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] }
        index = Index.new('test-index', mappings)
        index.stubs(:create_mappings_payload).returns(mappings)

        fake_settings = Struct.new(:elasticsearch_settings).new({ number_of_shards: 1 })
        Search::Settings.stubs(:current).returns(fake_settings)
        index.stubs(:sleep)

        Workarea.stubs(:elasticsearch).returns(client)
        index.create!

        assert_equal(3, indices.create_calls.size)
        assert_equal(mappings, indices.create_calls.first.dig(:body, :mappings))
        assert_equal(mappings, indices.create_calls[1].dig(:body, :mappings))
        assert_equal(mappings, indices.create_calls[2].dig(:body, :mappings))
      end

      def test_create_falls_back_to_typed_mappings_after_exhausting_retries
        cast_error = ::Elasticsearch::Transport::Transport::Errors::InternalServerError.new(
          '[500] {"error":{"type":"class_cast_exception","reason":"java.util.ArrayList cannot be cast to java.util.Map"}}'
        )

        indices = FakeIndices.new([cast_error, cast_error, cast_error, cast_error])
        client = FakeClient.new(indices)
        mappings = { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] }
        index = Index.new('test-index', mappings)
        index.stubs(:create_mappings_payload).returns(mappings)

        fake_settings = Struct.new(:elasticsearch_settings).new({ number_of_shards: 1 })
        Search::Settings.stubs(:current).returns(fake_settings)
        index.stubs(:sleep)

        Workarea.stubs(:elasticsearch).returns(client)
        index.create!

        assert_equal(5, indices.create_calls.size)
        assert_equal(
          { _doc: { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] } },
          indices.create_calls.last.dig(:body, :mappings)
        )
      end

      def test_bulk_includes_type_metadata_for_elasticsearch_6
        bulk_calls = []
        client = stub(
          'elasticsearch_6',
          info: { 'version' => { 'number' => '6.8.23' } },
          bulk: nil
        )
        client.define_singleton_method(:bulk) do |*args, **kwargs|
          bulk_calls << (args.first || kwargs)
        end

        index = Index.new('test-index', {})

        Workarea.stubs(:elasticsearch).returns(client)
        index.bulk([{ id: '1', name: 'Foo' }])

        metadata = bulk_calls.first[:body].first[:index]
        assert_equal('_doc', metadata[:_type])
      end

      def test_bulk_does_not_include_type_metadata_for_elasticsearch_7
        bulk_calls = []
        client = stub(
          'elasticsearch_7',
          info: { 'version' => { 'number' => '7.17.0' } },
          bulk: nil
        )
        client.define_singleton_method(:bulk) do |*args, **kwargs|
          bulk_calls << (args.first || kwargs)
        end

        index = Index.new('test-index', {})

        Workarea.stubs(:elasticsearch).returns(client)
        index.bulk([{ id: '1', name: 'Foo' }])

        metadata = bulk_calls.first[:body].first[:index]
        assert_nil(metadata[:_type])
      end

      def test_bulk_delete_includes_type_metadata_for_elasticsearch_6
        bulk_calls = []
        client = stub(
          'elasticsearch_6_delete',
          info: { 'version' => { 'number' => '6.8.23' } },
          bulk: nil
        )
        client.define_singleton_method(:bulk) do |*args, **kwargs|
          bulk_calls << (args.first || kwargs)
        end

        index = Index.new('test-index', {})

        Workarea.stubs(:elasticsearch).returns(client)
        index.bulk([{ id: '1', bulk_action: :delete }])

        metadata = bulk_calls.first[:body].first[:delete]
        assert_equal('_doc', metadata[:_type])
      end
    end
  end
end
