module Workarea
  class Storefront::PagesController < Storefront::ApplicationController
    before_action :cache_page

    def show
      model = Content::Page.find_by(slug: params[:id])
      raise InvalidDisplay unless model.active? || current_user.try(:admin?)
      @page = Storefront::PageViewModel.new(model, view_model_options)
    end

    def home_page
      @page = Storefront::ContentViewModel.new(
        Content.for('home_page'),
        view_model_options
      )
    end

    def robots; end
    def accessibility; end
    def browser_config; end
    def web_manifest; end

    private

    def page_specific_content_policy
      @page&.content_security_policy
    end
  end
end
