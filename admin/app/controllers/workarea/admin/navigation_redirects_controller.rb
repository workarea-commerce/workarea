module Workarea
  class Admin::NavigationRedirectsController < Admin::ApplicationController
    required_permissions :settings

    def index
      @redirect = Navigation::Redirect.new
      @redirects = Navigation::Redirect.search(params[:q])
        .page(params[:page])
        .order_by(find_sort(Navigation::Redirect))
    end

    def show
      @redirect = Navigation::Redirect.find(params[:id])
      redirect_to navigation_redirects_path(q: @redirect.path)
    end

    def create
      @redirect = Navigation::Redirect.new(params[:redirect])

      if @redirect.save
        flash[:success] = t('workarea.admin.navigation_redirects.flash_messages.created')
        redirect_to navigation_redirects_path
      else
        flash[:error] = @redirect.errors.full_messages.join(', ')
        redirect_to navigation_redirects_path, status: :unprocessable_entity
      end
    end

    def edit
      redirect_to navigation_redirects_path
    end

    def destroy
      @redirect = Navigation::Redirect.find(params[:id])
      @redirect.destroy

      flash[:success] = t('workarea.admin.navigation_redirects.flash_messages.removed')
      redirect_to navigation_redirects_path
    end
  end
end
