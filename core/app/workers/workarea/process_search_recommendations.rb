module Workarea
  class ProcessSearchRecommendations
    include Sidekiq::Worker

    def perform(*)
      predictor.clean!

      start = Workarea.config.recommendation_expiration.ago

      Recommendation::UserActivity
        .where(:updated_at.gte => start)
        .desc(:updated_at) # sort by updated_at to ensure use of that index
        .each_by(page_size) { |activity| add(activity) }

      predictor.process!
    end

    def predictor
      @predictor ||= Recommendation::SearchPredictor.new
    end

    def add(activity)
      searches = activity
                  .searches
                  .map { |s| QueryString.new(s).id }
                  .reject(&:blank?)

      predictor.sessions.add_set(activity.id.to_s, searches) if searches.many?
    end

    def page_size
      Workarea.config.search_recommendation_index_page_size
    end
  end
end
