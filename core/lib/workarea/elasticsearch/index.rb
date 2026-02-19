module Workarea
  module Elasticsearch
    class Index
      attr_reader :name, :mappings, :aliases

      def initialize(name, mappings, aliases = {})
        @name = name
        @mappings = mappings
        @aliases = aliases
      end

      def url
        host = Workarea.elasticsearch.transport.hosts.first
        "#{Workarea.elasticsearch.transport.__full_url(host)}/#{name}"
      end

      def exists?
        Workarea.elasticsearch.indices.exists?(index: name)
      end

      # Create the index, optionally deleting it first when +force+ is true.
      #
      # The previous implementation used an +unless exists?+ guard which
      # introduced a TOCTOU (time-of-check/time-of-use) race condition: the
      # cluster state visible to +exists?+ could differ from the state seen by
      # the subsequent +create+ call, causing intermittent
      # +resource_already_exists_exception+ (400) errors in CI and during rapid
      # sequential test runs.  When +create!+ raised that exception the index
      # remained deleted (because +delete!+ had already run), which caused the
      # cascade +index_not_found_exception+ (404) seen in later test operations.
      #
      # The fix removes the guard and instead rescues the 400 BadRequest that
      # Elasticsearch raises when the index already exists.  This makes the
      # operation atomic from the caller's perspective: if the index was already
      # present we simply skip creation, just as the old +unless exists?+ path
      # intended – but without the window for a concurrent creation to slip in.
      #
      def create!(force: false)
        delete! if force

        Workarea.elasticsearch.indices.create(
          index: name,
          body: {
            settings: Search::Settings.current.elasticsearch_settings,
            mappings: mappings,
            aliases: aliases
          }
        )
      rescue ::Elasticsearch::Transport::Transport::Errors::BadRequest => e
        raise unless e.message.include?('resource_already_exists_exception')
      end

      def delete!
        Workarea.elasticsearch.indices.delete(index: name, ignore: [404])
      end

      def while_closed
        Workarea.elasticsearch.indices.close(index: name)
        result = yield
        Workarea.elasticsearch.indices.open(index: name)
        result
      end

      def wait_for_health
        Workarea.elasticsearch.cluster.health(
          index: name,
          wait_for_status: 'yellow'
        )
      end

      # NOTE: We intentionally bypass the elasticsearch-ruby 5.x convenience
      # methods here. ES 7.x removed mapping types, but the 5.x client requires a
      # `type` argument for `index`, `update`, and `delete`. Using the transport
      # layer lets us hit the ES 7.x endpoints that don't accept a type parameter.
      def save(document, options = {})
        id = find_id_from(document)
        params = { refresh: Workarea.config.auto_refresh_search }.merge(options)
        body = document

        Workarea.elasticsearch.transport
          .perform_request('PUT', "#{name}/_doc/#{id}", params, body)
          .body
      end

      def update(document, options = {})
        id = find_id_from(document)
        params = { refresh: Workarea.config.auto_refresh_search }.merge(options)
        body = { doc: document }

        Workarea.elasticsearch.transport
          .perform_request('POST', "#{name}/_update/#{id}", params, body)
          .body
      end

      def bulk(documents, options = {})
        return if documents.blank?

        params = {
          index: name,
          refresh: Workarea.config.auto_refresh_search,
          body: documents.map do |document|
                  action = document.delete(:bulk_action).try(:to_sym) || :index

                  if action == :delete
                    { action => { _id: find_id_from(document) } }
                  else
                    { action => { _id: find_id_from(document), data: document } }
                  end
                end
        }

        Workarea.elasticsearch.bulk(params.merge(options))
      end

      def delete(id, options = {})
        params = { refresh: Workarea.config.auto_refresh_search, ignore: [404] }
          .merge(options)

        ignore = Array.wrap(params.delete(:ignore))

        Workarea.elasticsearch.transport
          .perform_request('DELETE', "#{name}/_doc/#{id}", params)
          .body
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound
        raise unless ignore.include?(404)
      end

      def search(query, options = {})
        query = if query.respond_to?(:to_h)
                  { index: name, body: query.to_h }
                else
                  { index: name, q: query.to_s }
                end

        Workarea.elasticsearch.search(query.merge(options))
      end

      def count(query = nil, options = {})
        query ||= { query: { match_all: {} } }
        total = search(query, options.merge(size: 0))['hits']['total']
        # ES 7.x returns { value: N, relation: "eq" }, older versions return integer
        total.is_a?(Hash) ? total['value'] : total
      end

      def scroll(scroll_id, options = {})
        Workarea.elasticsearch.scroll(
          {
            body: { scroll_id: scroll_id },
            scroll: Workarea.config.elasticsearch_default_scroll
          }.merge(options)
        )
      end

      def clear_scroll(*scroll_ids)
        scroll_id = scroll_ids.present? ? scroll_ids.join(',') : '_all'
        Workarea.elasticsearch.clear_scroll(scroll_id: scroll_id)
      end

      private

      def find_id_from(document)
        document[:id] || document['id'] || document[:_id] || document['_id']
      end
    end
  end
end
