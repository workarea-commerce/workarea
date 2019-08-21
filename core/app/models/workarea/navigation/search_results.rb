module Workarea
  module Navigation
    class SearchResults
      include GlobalID::Identification

      attr_reader :params

      def self.find(id)
        new(JSON.parse(id))
      end

      def initialize(params = {})
        @params = params
          .to_h
          .with_indifferent_access
          .except(*Workarea.config.exclude_from_search_results_breadcrumbs)

        stub_navigable_since_this_isnt_mongoid!
      end

      def id
        params.sort_by { |key, _| key }.to_h.to_json
      end

      def query_string
        @query_string ||= QueryString.new(params[:q])
      end

      def taxon
        @taxon ||= Taxon.new(
          parent_id: Taxon.root.id,
          parent_ids: [Taxon.root.id],
          name: I18n.t('workarea.breadcrumbs.search_results', query: params[:q])
        )
      end

      def ==(o)
        o.class == self.class && o.id == id
      end

      private

      def stub_navigable_since_this_isnt_mongoid!
        results = self
        taxon.define_singleton_method(:navigable) { results }
      end
    end
  end
end
