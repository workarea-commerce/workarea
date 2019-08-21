module Workarea
  class ProcessProductRecommendations
    include Sidekiq::Worker

    def perform(*)
      predictor.clean!

      start = Workarea.config.recommendation_expiration.ago

      Order
        .where(:placed_at.gte => start)
        .desc(:placed_at) # sort by placed_at to ensure use of that index
        .each_by(page_size) { |order| add(order) }

      predictor.process!
    end

    def predictor
      @predictor ||= Recommendation::ProductPredictor.new
    end

    def add(order)
      product_ids = order.items.map(&:product_id)
      predictor.orders.add_set(order.id.to_s, product_ids) if product_ids.many?
    end

    def page_size
      Workarea.config.product_recommendation_index_page_size
    end
  end
end
