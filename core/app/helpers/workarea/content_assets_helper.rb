module Workarea
  module ContentAssetsHelper
    # Returns the path to the given content asset, including the asset host
    # if one is configured via
    # `Rails.application.config.action_controller.asset_host` or passed as the
    # `host` option.
    #
    # @param content_asset [Workarea::Content::Asset]
    # @param options [Hash] any valid option for Rails' `url_to_asset`
    # @return [String] the content asset url string
    #
    def url_to_content_asset(content_asset, options={})
      source =  if content_asset.type == 'image'
                  content_asset.optim.url
                else
                  content_asset.url
                end

      url_to_asset(source, options)
    end
  end
end
