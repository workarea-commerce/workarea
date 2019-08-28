require 'test_helper'

module Workarea
  module Storefront
    class SearchSuggestionViewModelTest < TestCase
      setup :set_asset_host_config
      teardown :restore_asset_host_config

      def set_asset_host_config
        @current_asset_host = Rails.application.config.action_controller.asset_host
        Rails.application.config.action_controller.asset_host = 'http://cdn.client.com'
      end

      def restore_asset_host_config
        Rails.application.config.action_controller.asset_host = @current_asset_host
      end

      def test_image_handles_blank
        search_suggestion = { '_source' => { 'cache' => { 'image' => '' } } }
        view_model = SearchSuggestionViewModel.new(search_suggestion)
        assert(view_model.image.nil?)
      end

      def test_image_handles_different_urls_from_index
        possible_index_urls = %w(
          /image.jpg
          https://staging.client.com/image.jpg
          http://cdn.client.com/image.jpg
        )

        possible_index_urls.each do |url_from_index|
          search_suggestion = {
            '_source' => { 'cache' => { 'image' => url_from_index } }
          }

          view_model = SearchSuggestionViewModel.new(search_suggestion)
          assert_equal('http://cdn.client.com/image.jpg', view_model.image)
        end
      end
    end
  end
end
