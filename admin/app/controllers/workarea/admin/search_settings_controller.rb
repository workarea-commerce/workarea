module Workarea
  module Admin
    class SearchSettingsController < Admin::ApplicationController
      required_permissions :settings

      def show
        @settings = Search::Settings.current
        @price_facets = @settings.range_facets['price'] || []
      end

      def update
        clean_range_facets = CleanRangeFacets.new(params[:range_facets])
        attributes = {
          synonyms: params[:synonyms],
          boosts: params[:boosts].to_h.presence,
          views_factor: params[:views_factor],
          terms_facets_list: params[:terms_facets_list],
          range_facets: clean_range_facets.result.presence,
        }.merge(params[:settings] || {}).compact

        Search::Settings.current.update_attributes!(attributes)
        flash[:success] = t('workarea.admin.search_settings.flash_messages.saved')
        redirect_to return_to.presence || search_settings_path
      end
    end
  end
end
