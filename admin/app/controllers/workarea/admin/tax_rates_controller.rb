module Workarea
  module Admin
    class TaxRatesController < Admin::ApplicationController
      required_permissions :catalog

      def index
        model = Tax::Category.find(params[:tax_category_id])
        @category = TaxCategoryViewModel.wrap(model, view_model_options)

        @rates = @category.rates.page(params[:page])
      end
    end
  end
end
