module Workarea
  module Search
    class StorefrontSearch
      class Response
        Trace = Struct.new(:params, :query, :reset_by)

        attr_accessor :template, :message, :redirect, :params, :query,
          :customization, :trace

        def initialize(options = {})
          @template = options.fetch(:template, 'show')
          @message = options[:message]
          @redirect = options[:redirect]

          @params = options.fetch(:params, {})
          @params[:terms_facets] = terms_facets
          @params[:range_facets] = Settings.current.range_facets
          @original_params = @params.deep_dup

          @customization = options[:customization]
          @trace = []

          reset!(@params)
        end

        def redirect?
          @redirect.present?
        end

        # Reset the parameters and resulting query to match the new parameters
        # passed in. Used when correcting spelling, or auto filtering results.
        #
        # @param [Hash]
        #
        def reset!(params, by: nil)
          @params = params
          @query = Search::ProductSearch.new(params.merge(rules: product_rules))
          @trace << Trace.new(@params, @query, by)
        end

        def query_string
          params[:q].strip
        end

        def has_filters?
          query.facets.any?(&:selected?)
        end

        def autoselected_filter?(name)
          params[name].present? && @original_params[name].blank?
        end

        def total
          query.total
        end

        def query_suggestions
          @query.query_suggestions
        end

        def product_rules
          return [] if customization.blank?
          customization.product_rules.usable
        end

        private

        def terms_facets
          Search::Storefront::Product.current_terms_facets
        end
      end
    end
  end
end
