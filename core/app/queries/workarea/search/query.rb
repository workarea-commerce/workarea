module Workarea
  module Search
    module Query
      extend ActiveSupport::Concern
      include GlobalID::Identification

      included do
        attr_reader :params
      end

      module ClassMethods
        def document(klass = nil)
          @document ||= klass
        end

        def find(id)
          new(JSON.parse(id))
        end
      end

      Workarea.config.search_query_options.each do |option|
        define_method(option) {}
      end

      def initialize(params = {})
        @params = params.to_h.with_indifferent_access
      end

      def id
        params.to_json
      end

      def query_string
        @query_string ||= QueryString.new(params[:q])
      end

      def query
        { match_all: {} }
      end

      def post_filter
        {}
      end

      def aggregations
        {}
      end

      def body
        {
          query: query,
          post_filter: post_filter,
          aggs: aggregations
        }
        .merge(additional_options)
        .delete_if { |_, v| v.blank? }
      end

      def response
        @response ||= self.class.document.search(body)
      end

      def results
        @results ||= loaded_results
      end

      def total
        response['hits']['total']
      end

      def scroll(options = {}, &block)
        options = { scroll: Workarea.config.elasticsearch_default_scroll }.merge(options)
        results = self.class.document.search(body, options)
        scroll_id = results['_scroll_id']

        yield load_results(results)

        while (results = self.class.document.scroll(scroll_id, options)) && results['hits']['hits'].present?
          yield load_results(results)
          scroll_id = results['_scroll_id']
        end
      ensure
        self.class.document.clear_scroll(scroll_id) if scroll_id.present?
      end

      def loaded_results
        @loaded_results ||= load_results(response)
      end

      def stats
        return @stats if defined?(@stats)

        @stats = {}
        return @stats if response['aggregations'].blank?

        response['aggregations'].each do |name, data|
          if data['count'].present? || data[name].present?
            @stats[name] = data[name].present? ? data[name] : data
          end
        end

        @stats.each { |k, v| @stats.delete(k) if v.empty? }
        @stats
      end

      def load_model_from(document)
        Elasticsearch::Serializer.deserialize(document['_source'])
      end

      def additional_options
        Workarea.config.search_query_options.inject({}) do |options, option|
          options.merge(option => send(option))
        end
      end

      private

      def load_results(results)
        results['hits']['hits'].map do |document|
          source = document['_source']

          if source['model_class'].present? && source['model'].present?
            load_model_from(document)
          else
            source
          end
        end
      end
    end
  end
end
