module Workarea
  class Storefront::Users::AccountsController < Storefront::ApplicationController
    before_action :require_login, only: [:show, :edit, :update]
    before_action :require_logout, only: :create
    before_action :find_recommendations, only: :show

    def show
      @user = Storefront::UserViewModel.new(current_user)
    end

    def edit
      @user = Storefront::UserViewModel.new(current_user)
    end

    def create
      @user = User.new(user_params)

      if invalid_recaptcha?(action: 'signup')
        challenge_recaptcha!
        render 'workarea/storefront/users/logins/new', status: 422
      elsif @user.save
        login(@user)
        Login.new(@user, current_order).perform

        Storefront::AccountMailer.creation(@user.id.to_s).deliver_later
        save_completed_order_details(@user) if completed_order.present?
        Email.signup(@user.email) if params[:email_signup].present?

        flash[:success] = t('workarea.storefront.flash_messages.account_created')
        redirect_back_or users_account_path
      else
        flash[:error] = t('workarea.storefront.flash_messages.account_create_error')
        render 'workarea/storefront/users/logins/new', status: 422
      end
    end

    def update
      if current_user.update_attributes(user_params)
        update_email_signup
        flash[:success] = t('workarea.storefront.flash_messages.account_updated')
        redirect_to users_account_path
      else
        flash[:error] = current_user.errors.to_a.to_sentence
        current_user.reload

        @user = Storefront::UserViewModel.new(current_user)
        find_recommendations
        render :show
      end
    end

    def update_email_signup
      return unless params.key?(:email_signup)

      if params[:email_signup].to_s =~ /true/
        Email.signup(current_user.email)
      else
        Email.unsignup(current_user.email)
      end
    end

    private

    def find_recommendations
      @recommendations = Storefront::PersonalizedRecommendationsViewModel.new(
        current_metrics,
        view_model_options
      )
    end

    def user_params
      params.permit(
        :email,
        :password,
        :first_name,
        :last_name
      )
    end

    def save_completed_order_details(user)
      if user.email == completed_order.email
        completed_order.update_attributes!(user_id: user.id)
        SaveUserOrderDetails.new.perform(completed_order.id)
      end

      self.completed_order = nil
    end
  end
end
