require 'test_helper'

module Workarea
  module Storefront
    class CurrentCheckoutIntegrationTest < Workarea::IntegrationTest
      class CurrentCheckoutController < Storefront::ApplicationController
        def test
          current_order.save if params[:save]
          head :ok
        end
      end

      setup do
        Rails.application.routes.prepend do
          get 'current_checkout_test', to: "#{CurrentCheckoutController.controller_path}#test"
        end

        Rails.application.reload_routes!
      end

      def test_current_order
        get '/current_checkout_test'
        assert(session[:order_id].blank?)

        get '/current_checkout_test', params: { save: true }
        assert(session[:order_id].present?)
      end
    end
  end
end
