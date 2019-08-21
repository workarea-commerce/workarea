module Workarea
  module Admin
    class FeaturedProductsController < Admin::ApplicationController
      before_action :find_featurable
      before_action :check_publishing_authorization
      around_action :async_callbacks, only: %i(update add remove)

      def edit
        search = Search::AdminProducts.new(view_model_options)
        @search = Admin::SearchViewModel.new(search, view_model_options)
      end

      def update
        @featurable.update_attributes(product_ids: params[:product_ids])
        flash[:success] = t('workarea.admin.catalog_variants.flash_messages.saved')
        head :ok
      end

      def select
        search = Search::AdminProducts.new(view_model_options)
        @search = Admin::SearchViewModel.new(search, view_model_options)
      end

      def add
        product = Catalog::Product.find(params[:product_id])
        @featurable.add_product(product.id)

        flash[:success] = t(
          'workarea.admin.featured_products.flash_messages.added',
          name: product.name
        )

        render(
          partial: 'workarea/admin/featured_products/selected',
          locals: {
            featurable: @featurable,
            product: ProductViewModel.wrap(product)
          }
        )
      end

      def remove
        product = Catalog::Product.find(params[:product_id])
        @featurable.remove_product(product.id)

        flash[:success] = t(
          'workarea.admin.featured_products.flash_messages.removed',
          name: product.name
        )

        render(
          partial: 'workarea/admin/featured_products/unselected',
          locals: {
            featurable: @featurable,
            product: ProductViewModel.wrap(product)
          }
        )
      end

      def allow_publishing?
        super || !@featurable.active?
      end

      private

      def find_featurable
        model = GlobalID::Locator.locate(params[:id])
        @featurable = wrap_in_view_model(model, view_model_options)
      end

      # Changing featured products can cause lots of reindexing, which can
      # result in requests timing out.
      def async_callbacks
        Sidekiq::Callbacks.async { yield }
      end
    end
  end
end
