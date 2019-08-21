module Workarea
  module Admin
    class JumpToController < Admin::ApplicationController
      def index
        results = {
          results: Search::Admin.jump_to(params).map do |result|
            {
              label: result[:label],
              value: result[:label],
              type: result[:type].titleize.pluralize,
              url: result_url(result)
            }
          end
        }

        render json: results
      end

      private

      def result_url(result)
        if result[:to_param].present?
          send(result[:route_helper], result[:to_param])
        else
          send(result[:route_helper])
        end
      end
    end
  end
end
