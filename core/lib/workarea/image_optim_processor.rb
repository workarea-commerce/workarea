module Workarea
  module ImageOptimProcessor
    def self.call(content)
      if optimized = image_optim.optimize_image(content.path).presence
        content.update(optimized)
      end
    end

    def self.image_optim
      ImageOptim.new(Rails.application.config.assets.image_optim)
    end
  end
end
