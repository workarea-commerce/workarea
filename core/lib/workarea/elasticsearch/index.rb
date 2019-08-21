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

      def create!(force: false)
        delete! if force

        unless exists?
          Workarea.elasticsearch.indices.create(
            index: name,
            body: {
              settings: Search::Settings.current.elasticsearch_settings,
              mappings: mappings,
              aliases: aliases
            }
          )
        end
      end

      def delete!
        Workarea.elasticsearch.indices.delete(index: name, ignore: 404)
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

      def save(document, options = {})
        params = {
          index: name,
          id: find_id_from(document),
          body: document,
          refresh: Workarea.config.auto_refresh_search
        }

        Workarea.elasticsearch.index(params.merge(options))
      end

      def update(document, options = {})
        params = {
          index: name,
          id: find_id_from(document),
          body: { doc: document },
          refresh: Workarea.config.auto_refresh_search
        }

        Workarea.elasticsearch.update(params.merge(options))
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
        params = {
          index: name,
          id: id,
          refresh: Workarea.config.auto_refresh_search,
          ignore: [404]
        }

        Workarea.elasticsearch.delete(params.merge(options))
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
        search(query, options.merge(size: 0))['hits']['total']
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
