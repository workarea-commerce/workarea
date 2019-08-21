require 'test_helper'

module Workarea
  class ProcessSearchRecommendationsTest < Workarea::TestCase
    def test_processing_user_activity
      Metrics::User.create!(viewed: { search_ids: %w(foo bar) })
      2.times { Metrics::User.create!(viewed: { search_ids: %w(foo baz) }) }

      ProcessSearchRecommendations.new.perform

      predictor = Recommendation::SearchPredictor.new
      assert_equal(%w(baz bar), predictor.similarities_for('foo'))
    end

    def test_within_expiration
      Metrics::User.create!(viewed: { search_ids: %w(1 2) })
      travel_to((Workarea.config.recommendation_expiration + 1.day).from_now)
      2.times { Metrics::User.create!(viewed: { search_ids: %w(1 3) }) }

      ProcessSearchRecommendations.new.perform

      predictor = Recommendation::SearchPredictor.new
      assert_equal(%w(3), predictor.similarities_for('1'))
    end
  end
end
