module Workarea
  class Storefront::ProductsController < Storefront::ApplicationController
    before_action :cache_page

    def show
      model = Catalog::Product.find_by(slug: params[:id])
      raise InvalidDisplay unless model.active? || current_user.try(:admin?)

      @product = Storefront::ProductViewModel.wrap(
        model,
        view_model_options
      )
    end

    def details
      model = Catalog::Product.find_by(slug: params[:id])
      raise InvalidDisplay unless model.active? || current_user.try(:admin?)

      @product = Storefront::ProductViewModel.wrap(
        model,
        view_model_options
      )
    end
  end
end
