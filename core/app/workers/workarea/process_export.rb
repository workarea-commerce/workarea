module Workarea
  class ProcessExport
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker
    include Sidekiq::Throttled::Worker

    sidekiq_options(
      enqueue_on: { DataFile::Export => :create },
      queue: 'low',
      retry: false
    )

    sidekiq_throttle(concurrency: { limit: 1 })

    def perform(id)
      export = DataFile::Export.find(id)
      export.process!
      Admin::DataFileMailer.export(id).deliver_now
    end
  end
end
