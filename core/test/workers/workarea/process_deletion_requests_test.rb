require 'test_helper'

module Workarea
  class ProcessDeletionRequestsTest < TestCase
    def test_perform
      Sidekiq::Testing.fake!

      completed = Email::DeletionRequest.create!(email: 'test@workarea.com', process_at: 1.day.ago, completed_at: 1.hour.ago)
      ready = Email::DeletionRequest.create!(email: 'bclams@workarea.com', process_at: 1.day.ago, completed_at: nil)
      waiting = Email::DeletionRequest.create!(email: 'mmoss@workarea.com', process_at: 1.day.from_now)

      ProcessDeletionRequests.new.perform

      assert_equal(1, AnonymizeUserData.jobs.size)
    end
  end
end
