require 'test_helper'
require 'rack/mock'

module Workarea
  class MongoQueryCacheMiddlewareTest < TestCase
    class CommandSubscriber
      attr_reader :started_events

      def initialize
        @started_events = []
      end

      def started(event)
        @started_events << event
      end

      # required by Mongo monitoring interface
      def succeeded(_event); end
      def failed(_event); end
    end

    def setup
      super

      @client = Mongoid::Clients.default
      @collection = @client[:query_cache_middleware_test]
      @collection.drop
    end

    def teardown
      @collection.drop
      super
    end

    def test_query_cache_does_not_leak_between_requests
      doc_id = BSON::ObjectId.new
      @collection.insert_one(_id: doc_id, name: 'test')

      subscriber = CommandSubscriber.new
      @client.subscribe(Mongo::Monitoring::COMMAND, subscriber)

      rack_app = lambda do |_env|
        # Run the same query twice so we know the query cache is actually being
        # used within a single request.
        @collection.find(_id: doc_id).first
        result = @collection.find(_id: doc_id).first

        [200, { 'Content-Type' => 'text/plain' }, [result.fetch('name')]]
      end

      app = Mongo::QueryCache::Middleware.new(rack_app)
      request = Rack::MockRequest.new(app)

      find_count = lambda do
        subscriber.started_events.count do |event|
          event.command_name == 'find' && event.command['find'] == @collection.name
        end
      end

      before = find_count.call
      request.get('/')
      after_first = find_count.call

      request.get('/')
      after_second = find_count.call

      assert_equal 1,
        after_first - before,
        'Expected the first request to execute the find query once (second call served from cache)'

      assert_equal 1,
        after_second - after_first,
        'Expected the second request to execute the find query once (cache cleared between requests)'
    ensure
      @client.unsubscribe(Mongo::Monitoring::COMMAND, subscriber) if subscriber
    end
  end
end
