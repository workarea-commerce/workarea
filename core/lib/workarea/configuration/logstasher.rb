module Workarea
  module Configuration
    module Logstasher
      extend self

      def load
        if ENV['WORKAREA_LOGSTASH'] =~ /true/i
          Rails.application.config.logstasher.enabled = true
          Rails.application.config.logstasher.controller_enabled = true
          Rails.application.config.logstasher.suppress_app_log = true
          Rails.application.config.logstasher.source = `hostname`.strip!.to_s
        end
      end
    end
  end
end
