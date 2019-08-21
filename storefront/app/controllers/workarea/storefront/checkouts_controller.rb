module Workarea
  module Storefront
    class CheckoutsController < Storefront::ApplicationController
      layout :checkout_layout

      before_action :validate_checkout, only: :new
      before_action :validate_checkout_expiry, except: [:new, :confirmation]
      before_action :set_checkout_user, except: [:place_order, :confirmation]
      around_action :with_order_lock, unless: -> { request.get? }
      before_action :check_inventory, only: [:new, :place_order]
      before_action :touch_checkout, except: [:new, :confirmation]
      before_action :setup_view_models, except: :confirmation
      before_action { params.permit! } # TODO consider another, better way to handle this

      # GET /checkout
      def new
        redirect_to_next_step
      end

      private

      def redirect_to_next_step
        if current_checkout.complete?
          flash[:info] = t('workarea.storefront.flash_messages.review_your_order')
          redirect_to checkout_payment_path
        else
          redirect_to checkout_addresses_path
        end
      end

      def checkout_layout
        request.xhr? ? false : 'workarea/storefront/checkout'
      end

      def touch_checkout
        return unless current_order

        current_order.touch_checkout!(
          ip_address: request.remote_ip,
          user_activity_id: current_user_activity_id,
          checkout_by_id: current_admin.try(:id) || current_user.try(:id),
          source: current_admin.present? ? 'admin' : 'storefront',
          traffic_referrer: current_referrer,
          user_agent: request.user_agent
        )
      end

      def with_order_lock
        current_order.lock!
        yield
      rescue Workarea::Lock::Locked
        flash[:error] = t('workarea.storefront.flash_messages.checkout_lock_error')

        if request.xhr?
          head :conflict
        else
          redirect_to cart_path
        end

        return false
      ensure
        current_order.unlock! if current_order
      end

      def validate_checkout_expiry
        if !current_order || current_order.started_checkout? && !current_order.checking_out?
          flash[:warning] = t('workarea.storefront.flash_messages.checkout_expired')

          if request.xhr?
            flash.keep
            render js: "window.location = '#{cart_path}'", status: 422
          else
            redirect_to cart_path
          end

          return false
        end
      end

      def setup_view_models
        Pricing.perform(current_order, current_shippings)

        @cart = CartViewModel.new(current_order, view_model_options)
        @summary = Checkout::SummaryViewModel.new(
          current_checkout,
          view_model_options
        )
      end

      def set_checkout_user
        return if current_order.checking_out?

        if current_user.present?
          current_checkout.start_as(current_user)
        else
          current_checkout.start_as(:guest)
          logout
        end
      end
    end
  end
end
