module Workarea
  class ProcessReportsExport
    include Sidekiq::Worker
    include Sidekiq::CallbacksWorker
    include Sidekiq::Throttled::Worker

    sidekiq_options(enqueue_on: { Reports::Export => :create }, queue: 'low')
    sidekiq_throttle(concurrency: { limit: 1 })

    def perform(id)
      export = Reports::Export.find(id)

      export.process! do |csv|
        ExportReport.new(export.report, csv).perform!
      end

      Admin::ReportsMailer.export(id).deliver_now
    end
  end
end
