module Workarea
  class Storefront::Users::AddressesController < Storefront::ApplicationController
    before_action :require_login

    def new
      @address = current_user.addresses.build(address_params)
    end

    def create
      @address = current_user.addresses.create(address_params)

      if @address.persisted?
        flash[:success] = t('workarea.storefront.flash_messages.address_saved')
        redirect_to users_account_path
      else
        flash[:error] = t('workarea.storefront.flash_messages.address_save_error')
        render :new
      end
    end

    def edit
      @address = current_user.addresses.find(params[:id])
    end

    def update
      @address = current_user.addresses.find(params[:id])

      if @address.update_attributes(address_params)
        flash[:success] = t('workarea.storefront.flash_messages.address_saved')
        redirect_to users_account_path
      else
        flash[:error] = t('workarea.storefront.flash_messages.address_save_error')
        render :edit
      end
    end

    def destroy
      current_user.addresses.find(params[:id]).destroy
      flash[:success] = t('workarea.storefront.flash_messages.address_removed')
      redirect_to users_account_path
    end

    private

    def address_params
      params.permit(address: Workarea.config.address_attributes)[:address]
    end
  end
end
