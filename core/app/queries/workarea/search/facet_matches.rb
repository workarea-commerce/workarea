module Workarea
  module Search
    # TODO remove in v4, unused now
    class FacetMatches
      def initialize(params, facets)
        @params = params
        @facets = facets
      end

      def query
        @query ||= @params[:q].try(:strip).to_s
      end

      def matches
        @matches ||= @facets.reduce({}) do |memo, facet|
          facet.results.keys.each do |value|
            if query =~ /(^|\s+)#{Regexp.quote(value.to_s)}(\s+|$)/i
              memo[facet.system_name] ||= []
              memo[facet.system_name] << value
            end
          end

          memo
        end
      end

      def params
        return @params unless matches.keys.one?

        @_params ||= matches.reduce(@params) do |memo, tuple|
          name, values = *tuple
          memo[name] ||= []
          memo[name].push(*values)
          memo
        end
      end
    end
  end
end
