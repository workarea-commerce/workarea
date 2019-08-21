module Workarea
  module Search
    class StorefrontSearch
      class ProductMultipass
        include Middleware

        def last_pass?
          params[:pass] == ProductSearch::PASSES.last
        end

        def next_pass
          if params[:pass].blank?
            ProductSearch::PASSES.second
          else
            ProductSearch::PASSES.last
          end
        end

        def call(response, &traverse_chain)
          current_pass = response.query.response

          if sufficient_results?(current_pass)
            yield
          else
            pass_params = params.merge(pass: next_pass)
            new_pass = self.class.new(pass_params, customization)

            response.reset!(pass_params, by: self)
            new_pass.call(response, &traverse_chain)
          end
        end

        private

        def sufficient_results?(current_pass)
          valid_suggestion_from?(current_pass) ||
            last_pass? ||
              current_pass['hits']['total'] >=
                Workarea.config.search_sufficient_results
        end

        def valid_suggestion_from?(product_response)
          product_response['suggest'].present? &&
            product_response['suggest']['spelling_correction'].present? &&
            product_response['suggest']['spelling_correction'].first['options'].any?
        end
      end
    end
  end
end
