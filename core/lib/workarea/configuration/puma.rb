module Workarea
  module Configuration
    module Puma
      extend self

      def load(puma)
        puma.port(port)
        puma.threads(threads, threads)
        puma.environment(environment)

        if workers.present?
          puma.workers(workers)
          puma.preload_app!
        end

        puma.plugin(:tmp_restart)
        puma.set_remote_address(header: 'X-Real-IP') # For hosted environments
      end

      def port
        ENV.fetch('PORT') { 3000 }
      end

      def threads
        ENV.fetch('RAILS_MAX_THREADS') { 5 }
      end

      def environment
        ENV.fetch('RAILS_ENV') { 'development' }
      end

      def workers
        ENV.fetch('WEB_CONCURRENCY') { nil }
      end
    end
  end
end
