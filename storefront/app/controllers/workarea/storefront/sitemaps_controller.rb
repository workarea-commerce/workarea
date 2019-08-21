module Workarea
  module Storefront
    class SitemapsController < Storefront::ApplicationController
      before_action :cache_page

      def show
        @sitemap = TaxonomySitemap.new(view_model_options)
      end
    end
  end
end
