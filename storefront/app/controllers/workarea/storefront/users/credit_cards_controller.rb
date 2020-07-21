module Workarea
  class Storefront::Users::CreditCardsController < Storefront::ApplicationController
    before_action :require_login
    before_action :set_user, only: [:new, :create]

    def new
    end

    def create
      @credit_card = current_profile.credit_cards.create(credit_card_params)

      if @credit_card.persisted?
        flash[:success] = t('workarea.storefront.flash_messages.credit_card_saved')
        redirect_to users_account_path
      else
        flash[:error] = t('workarea.storefront.flash_messages.credit_card_save_error')
        render :new
      end
    end

    def edit
      @credit_card = current_profile.credit_cards.find(params[:id])
    end

    def update
      @credit_card = current_profile.credit_cards.find(params[:id])

      if @credit_card.update_attributes(credit_card_params)
        flash[:success] = t('workarea.storefront.flash_messages.credit_card_updated')
        redirect_to users_account_path
      else
        flash[:error] = t('workarea.storefront.flash_messages.credit_card_update_error')
        render :edit
      end
    end

    def destroy
      @credit_card = current_profile.credit_cards.find(params[:id])
      @credit_card.destroy

      flash[:success] = t('workarea.storefront.flash_messages.credit_card_removed')
      redirect_to users_account_path
    end

    private

    def set_user
      @user = Storefront::UserViewModel.new(current_user)
    end

    def current_profile
      @current_profile ||= Payment::Profile.lookup(
        PaymentReference.new(current_user)
      )
    end

    def credit_card_params
      cc_params = if params[:credit_card].blank?
                    {}
                  else
                    params[:credit_card].permit(
                      :first_name,
                      :last_name,
                      :default,
                      *Workarea.config.credit_card_attributes
                    )
                  end

      cc_params.merge(id: params[:id] || BSON::ObjectId.new)
    end
  end
end
