module Workarea
  module Admin
    class SearchAnalysisViewModel < ApplicationViewModel
      ScoredProduct = Struct.new(:product, :score, :featured) do
        delegate_missing_to :product
        alias_method :featured?, :featured
      end

      def storefront_search
        @storefront_search ||= Search::StorefrontSearch.new(q: model.query)
      end

      def scores
        @scores ||= storefront_search.response.query.results.map do |result|
          ScoredProduct.new(
            ProductViewModel.wrap(result[:model]),
            result[:raw]['_score'],
            last_used_customization.featured_product?(result[:model].id)
          )
        end
      end

      def trace
        storefront_search.response.trace
      end

      def middleware
        @middleware ||= begin
          past_last = false

          storefront_search.create_middleware_chain.reduce({}) do |memo, middleware|
            status = if past_last
              :ignore
            elsif middleware.is_a?(storefront_search.used_middleware.last.class)
              :last
            else
              :pass
            end

            past_last = middleware.is_a?(storefront_search.used_middleware.last.class) unless past_last
            memo.merge(middleware.class => status)
          end
        end
      end

      def last_used_customization
        trace.last.query.customization
      end

      def tokens
        @tokens ||= begin
          terms_used = trace.last.query.query_string.sanitized

          options = Workarea
            .config
            .elasticsearch_settings
            .dig(:analysis, :analyzer, :text_analyzer)
            .except(:char_filter)
            .merge(index: Search::Storefront.current_index.name, text: terms_used)

          Workarea.elasticsearch.indices.analyze(options)['tokens'].reduce({}) do |memo, result|
            memo.merge(result['token'] => result['type'].gsub(/\W/, ''))
          end
        end
      end
    end
  end
end
