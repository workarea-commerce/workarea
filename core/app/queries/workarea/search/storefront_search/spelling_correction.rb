module Workarea
  module Search
    class StorefrontSearch
      class SpellingCorrection
        include Middleware

        def call(response)
          if correction = find_spell_correction(response)
            response.reset!(params.merge(q: correction), by: self)
            response.message = I18n.t(
              'workarea.storefront.searches.showing_suggested_results',
              suggestion: correction,
              original: params[:q].to_s.strip
            )
          end

          yield
        end

        def find_spell_correction(response)
          return nil if response.has_filters? || any_results?(response)
          response.query.query_suggestions.first
        end

        def any_results?(response)
          response.total > 0
        end
      end
    end
  end
end
