module Workarea
  class GenerateInsights
    include Sidekiq::Worker
    delegate :perform, to: :class

    class << self
      def generate_all!
        generate_daily_insights
        generate_weekly_insights
        generate_monthly_insights
      end

      def perform(*)
        generate_daily_insights
        generate_weekly_insights if Time.current.monday?
        generate_monthly_insights if Time.current.day == 1
      end

      def generate_daily_insights
        Insights::Base.subclasses.each(&:generate_daily!)
      end

      def generate_weekly_insights
        Metrics::ProductForLastWeek.aggregate!
        Metrics::ProductByWeek.append_last_week!
        Metrics::SearchForLastWeek.aggregate!
        Metrics::SearchByWeek.append_last_week!
        Metrics::UpdateUserAggregations.update!
        Insights::Base.subclasses.each(&:generate_weekly!)
      end

      def generate_monthly_insights
        Insights::Base.subclasses.each(&:generate_monthly!)
      end
    end
  end
end
