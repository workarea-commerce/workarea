module Workarea
  class ProcessSearchRecommendations
    include Sidekiq::Worker

    def perform(*)
      predictor.clean!

      start = Workarea.config.recommendation_expiration.ago

      Metrics::User
        .where(:updated_at.gte => start)
        .desc(:updated_at) # sort by updated_at to ensure use of that index
        .each_by(page_size) { |metrics| add(metrics) }

      predictor.process!
    end

    def predictor
      @predictor ||= Recommendation::SearchPredictor.new
    end

    def add(metrics)
      return unless metrics.viewed.search_ids.many?
      predictor.sessions.add_set(metrics.id, metrics.viewed.search_ids)
    end

    def page_size
      Workarea.config.search_recommendation_index_page_size
    end
  end
end
