module Workarea
  module Admin
    class CreateUsersController < Admin::ApplicationController
      include UserParams

      required_permissions :people
      before_action :find_user

      def index
        redirect_to new_create_user_path unless current_user.permissions_manager?
      end

      def new
        render_form
      end

      def create
        @user.attributes = user_params
        @user.password ||= "#{SecureRandom.hex(20)}_aA1" # extra chars to appease requirements

        if !@user.save
          render_form
        else
          apply_store_credit

          flash[:success] = t('workarea.admin.create_users.flash_messages.created')

          if params[:send_account_creation_email].to_s =~ /true/
            Storefront::AccountMailer.creation(@user.id.to_s).deliver_later
          end

          if !@user.admin? && params[:impersonate].to_s =~ /true/
            impersonate_user(@user)
            redirect_to storefront.users_account_path
          else
            redirect_to user_path(@user)
          end
        end
      end

      private

      def find_user
        @user = User.new(user_params)
      end

      def render_form
        if params[:type] == 'admin' || @user.admin?
          render :admin
        else
          render :customer
        end
      end

      def apply_store_credit
        return unless params.dig(:profile, :store_credit).present?

        payment_profile = Payment::Profile.lookup(PaymentReference.new(@user))
        payment_profile.update_attributes(
          store_credit: params.dig(:profile, :store_credit)
        )
      end
    end
  end
end
