module Workarea
  module Search
    module Facets
      extend ActiveSupport::Concern

      def facets
        @facets ||= terms_facets + range_facets
      end

      def terms_facets
        Array(params[:terms_facets]).map do |term_facet|
          TermsFacet.new(self, term_facet)
        end
      end

      def range_facets
        return [] if params[:range_facets].blank?

        params[:range_facets].keys.map do |range_facet|
          RangeFacet.new(
            self,
            range_facet,
            params[:range_facets].fetch(range_facet, [])
          )
        end
      end
    end
  end
end
