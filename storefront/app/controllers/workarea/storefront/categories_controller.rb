module Workarea
  class Storefront::CategoriesController < Storefront::ApplicationController
    before_action :cache_page

    def show
      model = Catalog::Category.find_by(slug: params[:id])
      raise InvalidDisplay unless model.active? || current_user.try(:admin?)
      @category = Storefront::CategoryViewModel.new(model, view_model_options)
    end

    private

    def page_specific_content_policy
      @category&.content_security_policy
    end
  end
end
