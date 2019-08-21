module Workarea
  module Admin
    class SearchCustomizationsController < Admin::ApplicationController
      required_permissions :search

      before_action :check_publishing_authorization
      before_action :find_customization, except: :index

      def index
        if request.xhr?
          @customizations = Search::Customization.autocomplete(params[:q])
        else
          customizations =
            Search::Customization
              .all
              .page(params[:page])
              .per(Workarea.config.per_page)
              .order_by(find_sort(Search::Customization))

          @customizations = PagedArray.from(
            SearchCustomizationViewModel.wrap(customizations),
            params[:page],
            Workarea.config.per_page,
            customizations.total_count
          )
        end
      end

      def create
        if @customization.persisted? || @customization.save
          flash[:success] = t('workarea.admin.search_customizations.flash_messages.created', query: @customization.query)
          redirect_to search_customization_path(@customization)
        else
          flash[:error] = t('workarea.admin.search_customizations.flash_messages.saved_error')
          redirect_back fallback_location: root_path
        end
      end

      def show
      end

      def edit
      end

      def update
        if @customization.update_attributes(params[:customization])
          flash[:success] = t('workarea.admin.search_customizations.flash_messages.saved')
          redirect_to search_customization_path(@customization)
        else
          flash[:error] = t('workarea.admin.search_customizations.flash_messages.saved_error')
          render :new
        end
      end

      def insights
      end

      def analyze
        @analysis = Admin::SearchAnalysisViewModel.wrap(@customization, view_model_options)
      end

      def destroy
        @customization.destroy
        flash[:success] = t(
          'workarea.admin.search_customizations.flash_messages.removed',
          query: @customization.query
        )
        redirect_to search_customizations_path
      end

      private

      def find_customization
        model = Search::Customization.find(params[:id]) rescue
                  Search::Customization.find_by_query(params[:q])

        @customization = Admin::SearchCustomizationViewModel.new(
          model,
          view_model_options
        )
      end
    end
  end
end
