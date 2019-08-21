module Workarea
  module Admin
    class NavigationMenusController < Admin::ApplicationController
      required_permissions :store

      before_action :check_publishing_authorization
      before_action :find_menu, except: :index
      before_action :find_content, except: :index
      before_action :find_taxons, except: :index

      def index
        @menus = Navigation::Menu.all.sort_by(&:position)

        @menu = if params[:menu_id].present?
                  Navigation::Menu.find(params[:menu_id])
                else
                  @menus.first
                end

        if @menu.present?
          @content = ContentViewModel.wrap(Content.for(@menu), params)
        end

        @menus_sorted = SortNavigationMenusByOrders.new.sorted_menus
      end

      def show
        redirect_to edit_navigation_menu_path(@menu)
      end

      def create
        if @menu.save
          flash[:success] = t('workarea.admin.navigation_menus.flash_messages.created')
          redirect_to navigation_menus_path(menu_id: @menu)
        else
          flash[:error] = t('workarea.admin.navigation_menus.flash_messages.created_error')
          render :new
        end
      end

      def edit
      end

      def update
        if @menu.update_attributes(params[:menu])
          flash[:success] = t('workarea.admin.navigation_menus.flash_messages.updated')
          redirect_to navigation_menus_path(menu_id: @menu)
        else
          flash[:error] = t('workarea.admin.navigation_menus.flash_messages.updated_error')
          render :edit
        end
      end

      def sort
        SortNavigationMenusByOrders.perform
        flash[:success] = t('workarea.admin.navigation_menus.flash_messages.sorted')
        redirect_to navigation_menus_path
      end

      def move
        position_data = params.fetch(:positions, {})

        position_data.each do |menu_id, position|
          Navigation::Menu.find(menu_id).update_attributes!(position: position)
        end

        flash[:success] = t('workarea.admin.navigation_menus.flash_messages.moved')
        head :ok
      end

      def destroy
        if current_release.present?
          @menu.active = false
          @menu.save
        else
          @menu.destroy
        end

        flash[:success] = t('workarea.admin.navigation_menus.flash_messages.removed')
        redirect_to navigation_menus_path
      end

      private

      def find_menu
        @menu = if params[:id].present?
                  Navigation::Menu.find(params[:id])
                else
                  Navigation::Menu.new(params[:menu])
                end
      end

      def find_content
        if @menu.persisted?
          @content = ContentViewModel.wrap(Content.for(@menu), params)
        end
      end

      def find_taxons
        @taxons = Navigation::Taxon.where(depth: 1).to_a
      end
    end
  end
end
