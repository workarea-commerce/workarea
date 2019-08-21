module Workarea
  module Search
    class Settings
      include ApplicationDocument

      field :index, type: String
      field :synonyms, type: String
      field :views_factor, type: Float, default: Workarea.config.default_search_views_factor
      field :boosts, type: Hash, default: Workarea.config.default_search_boosts
      field :terms_facets, type: Array, default: []
      field :range_facets, type: Hash, default: {}
      list_field :terms_facets

      around_update :update_indexes

      # The site-specific {Search::Settings} to use for the current request.
      # Thread-safe.
      #
      # @return [Search::Settings]
      #
      def self.current
        Thread.current[:current_search_settings] ||
          find_or_create_by(index: Elasticsearch::Document.current_index_prefix)
      end

      def self.current=(settings)
        Thread.current[:current_search_settings] = settings
      end

      # For compatibility with admin features, models must respond to this method.
      #
      # @return [String]
      #
      def name
        'Search Settings'
      end

      def sanitized_synonyms
        result = synonyms.to_s.split(/\r?\n/)

        # empty synonym filter breaks everything!
        if result.blank?
          ['synonims, synonyms']
        else
          result.map do |line|
            line.gsub(/[-–]/, ' ').gsub(/\s?,\s?/, ',').gsub(/(\A\s|\s\z)/, '').downcase
          end
        end
      end

      # The settings for creation of Elasticsearch indexes. Using them from here
      # adds the synonyms as defined by the admin.
      #
      # @return [Hash]
      #
      def elasticsearch_settings
        result = Workarea.config.elasticsearch_settings.deep_dup

        result[:analysis][:filter][:synonym] = {
          type: 'synonym',
          synonyms: sanitized_synonyms
        }

        result
      end

      private

      def update_indexes
        should_update_synonyms = synonyms_changed?
        success = yield

        if should_update_synonyms && success
          UpdateElasticsearchSettings.perform_async(elasticsearch_settings)
        end
      end
    end
  end
end
