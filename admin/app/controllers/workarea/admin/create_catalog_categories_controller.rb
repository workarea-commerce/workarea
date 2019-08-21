module Workarea
  module Admin
    class CreateCatalogCategoriesController < Admin::ApplicationController
      required_permissions :catalog

      before_action :find_category

      before_action :find_product_rules, only: [:rules, :new_rule, :edit_rule]
      before_action :find_product_rule, only: [:new_rule, :edit_rule]

      before_action :find_taxon, only: [:taxonomy, :save_taxonomy]
      before_action :allow_publishing!, only: :content

      def index
        render :setup
      end

      def create
        @category.attributes = params[:category]

        if @category.save
          flash[:success] = t('workarea.admin.create_catalog_categories.flash_messages.saved')
          redirect_to products_create_catalog_category_path(@category)
        else
          render :setup, status: :unprocessable_entity
        end
      end

      def edit
        render :setup
      end

      def products
      end

      def featured_products
        search = Search::AdminProducts.new(view_model_options)
        @search = SearchViewModel.new(search, view_model_options)
      end

      def rules
      end

      def new_rule
        render :rules
      end

      def edit_rule
        render :rules
      end

      def content
        model = Content.for(@category.model)
        @content = ContentViewModel.new(model, view_model_options)
      end

      def taxonomy
      end

      def save_taxonomy
        save = SaveTaxonomy.new(@taxon, params)
        save.perform
        flash[:success] = t('workarea.admin.create_catalog_categories.flash_messages.saved')

        if save.top_level?
          redirect_to navigation_create_catalog_category_path(@category)
        else
          redirect_to publish_create_catalog_category_path(@category)
        end
      end

      def navigation
      end

      def save_navigation
        if params[:create_menu].to_s =~ /true/
          Navigation::Menu.create!(taxon: @category.taxon)
          flash[:success] = t('workarea.admin.create_catalog_categories.flash_messages.saved')
        end

        redirect_to publish_create_catalog_category_path(@category)
      end

      def publish
      end

      def save_publish
        publish = SavePublishing.new(@category, params)

        if publish.perform
          flash[:success] = t('workarea.admin.create_catalog_categories.flash_messages.created')
          redirect_to catalog_category_path(@category)
        else
          flash[:error] = publish.errors.full_messages
          render :publish
        end
      end

      private

      def find_category
        model = if params[:id].present?
                  Catalog::Category.find_by(slug: params[:id])
                else
                  Catalog::Category.new(params[:category])
                end

        @category = CategoryViewModel.new(model, view_model_options)
      end

      def find_product_rules
        @product_rules = @category.product_rules.select(&:persisted?)
        @preview = ProductRulesPreviewViewModel.wrap(
          @category.model,
          view_model_options
        )
      end

      def find_product_rule
        @product_rule = if params[:rule_id].present?
                          @category.product_rules.where(id: params[:rule_id]).first
                        else
                          @category
                            .model
                            .product_rules
                            .build(params[:product_rule])
                        end
      end

      def find_taxon
        @taxon = SaveTaxonomy.build(@category.model)
      end
    end
  end
end
