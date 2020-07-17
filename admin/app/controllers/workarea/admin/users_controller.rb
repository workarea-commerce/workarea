module Workarea
  module Admin
    class Admin::UsersController < Admin::ApplicationController
      include UserParams

      required_permissions :people

      before_action :find_user, except: :index
      around_action :inline_metrics_synchronizing
      after_action :track_index_filters, only: :index

      def index
        search_params = params.merge(autocomplete: request.xhr?)

        respond_to do |format|
          format.html do
            search = Search::AdminUsers.new(search_params)
            @search = Admin::UserSearchViewModel.new(search, view_model_options)
          end

          format.json do
            search = Search::AdminUsers.new(search_params.merge(role: ['Administrator']))
            @results =
              Admin::UserSearchViewModel.new(search, view_model_options).results.reject do |result|
                result.id == current_user.id && params[:exclude_current_user]
              end
          end
        end
      end

      def show
      end

      def edit
      end

      def update
        if @user.update_attributes(user_params)
          update_email_signup
          @user.payment_profile.update_attributes(params[:payment])
          flash[:success] = t('workarea.admin.users.flash_messages.saved')
          redirect_to user_path(@user)
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def orders
      end

      def cart
        @order = @user.latest_cart
      end

      def permissions
        unauthorized_user and return unless current_user.permissions_manager?
      end

      def addresses
      end

      def insights
        models = Workarea::Insights::Base.by_customer(@user.email)
        @insights = InsightViewModel.wrap(models, view_model_options)
      end

      def send_password_reset
        password_reset = User::PasswordReset.create!(user: @user.model)
        Storefront::AccountMailer.password_reset(password_reset.id.to_s).deliver_later

        flash[:success] = t('workarea.admin.users.flash_messages.password_reset')
        redirect_to user_path(@user)
      end

      def unlock
        @user.unlock_login!
        flash[:success] = t('workarea.admin.users.flash_messages.unlocked')
        redirect_to user_path(@user)
      end

      private

      def update_email_signup
        if params[:email_signup].to_s =~ /true/ && !@user.email_signup?
          Email.signup(@user.email)
        elsif params[:email_signup].to_s =~ /false/
          Email.unsignup(@user.email)
        end
      end

      def find_user
        @user = Admin::UserViewModel.new(User.find(params[:id]))
      end

      def inline_metrics_synchronizing
        Sidekiq::Callbacks.inline(SynchronizeUserMetrics) { yield }
      end
    end
  end
end
