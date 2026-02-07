module Workarea
  module Configuration
    module Elasticsearch
      extend self

      def find
        workarea_config.presence || secrets_config.presence || env_config
      end

      def workarea_config
        deep_convert_hash_like(Workarea.config.elasticsearch || {})
          .deep_symbolize_keys
      end

      def secrets_config
        result = deep_convert_hash_like(Rails.application.secrets.elasticsearch || {})
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

      # Avoid passing BSON::Document instances into ActiveSupport's deep key
      # transforms, which will call the deprecated BSON::Document#deep_symbolize_keys!
      # in bson >= 5.
      def deep_convert_hash_like(value)
        if defined?(::BSON::Document) && value.is_a?(::BSON::Document)
          value.to_h.transform_values { |v| deep_convert_hash_like(v) }
        elsif value.is_a?(::Hash)
          value.to_h.transform_values { |v| deep_convert_hash_like(v) }
        elsif value.is_a?(::Array)
          value.map { |v| deep_convert_hash_like(v) }
        else
          value
        end
      end

      def env_hosts
        ENV
          .select { |k| k =~ /^WORKAREA_ELASTICSEARCH_URL_\d+$/ }
          .map(&:last)
          .reject(&:blank?)
      end
    end
  end
end
