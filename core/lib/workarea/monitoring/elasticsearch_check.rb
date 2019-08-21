module Workarea
  module Monitoring
    class ElasticsearchCheck

      def check
        status = Workarea.elasticsearch.cluster.health.try(:[], 'status')

        if status_ok?(status)
          [true, 'Up']
        else
          [false, 'Down']
        end
      end

      private

      def status_ok?(status)
        status &&
          (Rails.env.production?  && status == 'green') ||
          (!Rails.env.production? && status != 'red')
      end
    end
  end
end
