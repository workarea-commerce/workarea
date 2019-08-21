module Workarea
  module Configuration
    module Elasticsearch
      extend self

      def find
        workarea_config.presence || secrets_config.presence || env_config
      end

      def workarea_config
        (Workarea.config.elasticsearch || {}).deep_symbolize_keys
      end

      def secrets_config
        result = Rails.application.secrets.elasticsearch || {}
        result.deep_dup.deep_symbolize_keys
      end

      def env_config
        if env_hosts.present?
          { urls: env_hosts }
        elsif ENV['WORKAREA_ELASTICSEARCH_URL'].present?
          { url: ENV['WORKAREA_ELASTICSEARCH_URL'] }
        else
          { url: 'localhost:9200', logger: Rails.logger }
        end
      end

      private

      def env_hosts
        ENV
          .select { |k| k =~ /^WORKAREA_ELASTICSEARCH_URL_\d+$/ }
          .map(&:last)
          .reject(&:blank?)
      end
    end
  end
end
