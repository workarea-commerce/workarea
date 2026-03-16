module Workarea
  Core::Engine.routes.draw do
    # Prototype replacement endpoint for non-Dragonfly media.
    # NOTE: uses a different prefix to avoid conflicting with Dragonfly's `/media/:job/:name` middleware.
    get 'media2/:uid/:filename' => 'media#show', as: :media_v2

    get 'product_images/:slug(/:option)/:image_id/:job.jpg' => Dragonfly.app(:workarea).endpoint { |*args|
      AssetEndpoints::ProductImages.new(*args).result
    }, as: :dynamic_product_image

    get 'product_images/placeholder/:job.jpg' => Dragonfly.app(:workarea).endpoint { |*args|
      AssetEndpoints::ProductPlaceholderImages.new(*args).result
    }, as: :product_image_placeholder

    mount Easymon::Engine => "/up"
  end
end
