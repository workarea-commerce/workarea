module Workarea
  class CleanProductRecommendations
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker

    sidekiq_options enqueue_on: { Catalog::Product => :destroy }

    def perform(id)
      predictor = Recommendation::ProductPredictor.new
      predictor.delete_item!(id)
    end
  end
end
