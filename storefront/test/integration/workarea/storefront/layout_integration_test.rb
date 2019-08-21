require 'test_helper'

module Workarea
  module Storefront
    class LayoutIntegrationTest < Workarea::IntegrationTest
      class LayoutController < Storefront::ApplicationController
        def test
          render inline: 'Foo bar', layout: current_layout
        end
      end

      setup do
        Rails.application.routes.prepend do
          get 'layout_test', to: "#{LayoutController.controller_path}#test"
        end

        Rails.application.reload_routes!
      end

      def test_layout
        get '/layout_test'
        assert_match(/<html/, response.body)

        get '/layout_test', xhr: true
        refute_match(/<html/, response.body)
      end
    end
  end
end
