module Workarea
  class CleanUserActivity
    include Sidekiq::Worker

    def perform(*args)
      Recommendation::UserActivity.
        where(:updated_at.lt => Time.current - 3.months).
        delete_all
    end
  end
end
