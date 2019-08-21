module Workarea
  class ProcessDirectUpload
    include Sidekiq::Worker
    sidekiq_options(queue: 'low')

    def perform(type, filename)
      DirectUpload.new(type, filename).process!
    end
  end
end
