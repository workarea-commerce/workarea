module Workarea
  class ProcessDeletionRequests
    include Sidekiq::Worker

    def perform(*)
      Email::DeletionRequest.awaiting_processing.each do |request|
        AnonymizeUserData.perform_async(request.id)
      end
    end
  end
end
