module Workarea
  module Monitoring
    class SidekiqQueueSizeCheck

      def check
        length = Sidekiq::Queue.all.sum(&:size)
        status = length < Workarea.config.sidekiq_critical_queue_size

        [status, "#{status ? 'Low' : 'High'} - #{length}"]

      rescue
        [false, 'Down']
      end
    end
  end
end
