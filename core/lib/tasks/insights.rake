require 'workarea/tasks/insights'

namespace :workarea do
  namespace :insights do
    desc 'Creates metrics and insights based on orders'
    task generate: :environment do
      Workarea::Tasks::Insights.generate
      puts "Success! Generated #{Workarea::Insights::Base.count} insights."
    end

    # Clear the metrics/insights environment - deletes lots of data, this task
    # is very dangerous! Useful for testing/debugging.
    task reset: :environment do
      Workarea::Tasks::Insights.reset!
      puts "Success! Insights and metrics have been cleared."
    end
  end
end
