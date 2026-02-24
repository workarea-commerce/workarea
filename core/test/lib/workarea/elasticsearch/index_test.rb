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
        index = Index.new('test-index', dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }])

        fake_settings = Struct.new(:elasticsearch_settings).new(number_of_shards: 1)
        Search::Settings.stubs(:current).returns(fake_settings)

        Workarea.stub(:elasticsearch, client) do
          index.create!
        end

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
        index = Index.new('test-index', dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }])

        fake_settings = Struct.new(:elasticsearch_settings).new(number_of_shards: 1)
        Search::Settings.stubs(:current).returns(fake_settings)

        Workarea.stub(:elasticsearch, client) do
          index.create!
        end

        assert_equal(2, indices.create_calls.size)
        assert_equal(
          { _doc: { dynamic_templates: [{ foo: { mapping: { type: 'keyword' } } }] } },
          indices.create_calls.last.dig(:body, :mappings)
        )
      end
    end
  end
end
