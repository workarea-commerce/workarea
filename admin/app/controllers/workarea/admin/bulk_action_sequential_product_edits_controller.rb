module Workarea
  module Admin
    class BulkActionSequentialProductEditsController < Admin::ApplicationController
      include BulkVariantSaving

      required_permissions :catalog

      before_action :find_bulk_action
      before_action :find_product, only: [:product, :update_product]

      def edit
        render :publishing
      end

      def publish
        publish = SavePublishing.new(nil, params)

        if publish.perform
          self.current_release = publish.release
          redirect_to first_product_path
        else
          flash[:error] = publish.errors.full_messages
          render :publishing
        end
      end

      def product
      end

      def update_product
        set_details
        set_filters
        set_images
        set_variants

        if @product.update_attributes(params[:product])
          if @bulk_action.last?
            flash[:success] = t('workarea.admin.bulk_action_sequential_product_edits.flash_messages.done')
            redirect_to catalog_products_path
          else
            flash[:success] = t('workarea.admin.bulk_action_sequential_product_edits.flash_messages.saved')
            redirect_to next_product_path
          end
        else
          flash[:error] = @product.errors.full_messages
          render :product, status: :unprocessable_entity
        end
      end

      private

      def find_bulk_action
        model = BulkAction::SequentialProductEdit.find(params[:id])
        @bulk_action = Admin::BulkActionSequentialProductEditViewModel.new(
          model,
          view_model_options
        )
      end

      def find_product
        model = @bulk_action.find_product(params[:index])
        @product = ProductViewModel.wrap(model, view_model_options)
        @variants = VariantViewModel.wrap(model.variants)
      end

      def set_details
        @product.details = HashUpdate.new(
          original: @product.details,
          adds: params[:new_details],
          updates: params[:details],
          removes: params[:details_to_remove]
        ).result
      end

      def set_filters
        @product.filters = HashUpdate.new(
          original: @product.filters,
          adds: params[:new_filters],
          updates: params[:filters],
          removes: params[:filters_to_remove]
        ).result
      end

      def set_images
        if params[:image_updates].present?
          params[:image_updates].each do |id, attrs|
            @product.images.find(id).update_attributes!(attrs)
          end
        end

        if params[:new_images].present?
          params[:new_images].each do |attrs|
            @product.images.create!(attrs) if attrs[:image].present?
          end
        end
      end

      def set_variants
        Array(params[:variants]).each do |attrs|
          variant =
            if attrs['id'].present?
              @product.variants.detect { |v| v.id.to_s == attrs['id'] }
            end

          if attrs[:sku].present?
            save_variant_on_product(@product, variant: variant, attributes: attrs)
          elsif variant.present?
            variant.destroy
          end
        end
      end

      def first_product_path
        product_bulk_action_sequential_product_edit_path(
          @bulk_action,
          index: 0
        )
      end

      def next_product_path
        product_bulk_action_sequential_product_edit_path(
          @bulk_action,
          index: @bulk_action.next
        )
      end
    end
  end
end
