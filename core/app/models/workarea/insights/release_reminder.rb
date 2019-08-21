module Workarea
  module Insights
    class ReleaseReminder < Base
      class << self
        def dashboards
          %w(store)
        end

        def generate_daily!
          releases = Release
            .tomorrow
            .soonest
            .limit(Workarea.config.insights_releases_list_max_results)

          create!(results: releases.map { |r| { release_id: r.id } }) if releases.present?
        end
      end
    end
  end
end
