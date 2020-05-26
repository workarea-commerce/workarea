module Workarea
  class ProcessImport
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker
    include Sidekiq::Throttled::Worker

    sidekiq_options(
      enqueue_on: { DataFile::Import => :create },
      queue: 'low',
      retry: false
    )

    sidekiq_throttle(concurrency: { limit: 1 })

    def perform(id)
      import = DataFile::Import.find(id)
      import.process!

    ensure
      if import&.error?
        Admin::DataFileMailer.import_error(id).deliver_now
      elsif import&.failure?
        Admin::DataFileMailer.import_failure(id).deliver_now
      elsif import.present?
        Admin::DataFileMailer.import(id).deliver_now
      end
    end
  end
end
