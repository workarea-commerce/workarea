module Workarea
  module Configuration
    class MongoidClient
      def initialize(name = nil)
        @name = name
        @default = MongoidClient.new unless name.nil?
      end

      def to_h
        {
          database: database,
          hosts: hosts,
          options: options
        }
      end

      def database
        "#{Workarea.config.site_name.systemize}_#{Rails.env}"
      end

      def hosts
        env_hosts =
          ENV.select { |k| k =~ /^#{env_key}_HOST(?:_\d+)?$/ }
             .map(&:last)
             .reject(&:blank?)

        env_hosts.presence || @default&.hosts || ['localhost:27017']
      end

      def options
        JSON.parse(ENV["#{env_key}_OPTIONS"].presence || '{}')
            .deep_symbolize_keys
            .reverse_merge(@default&.options || {})
            .reverse_merge(max_pool_size: max_pool_size)
      rescue JSON::ParserError
        {}
      end

      private

      def env_key
        ['WORKAREA', 'MONGOID', @name.to_s.underscore.upcase]
          .reject(&:blank?)
          .join('_')
      end

      # TODO: Remove this in v3.5 in favor of using WORKAREA_MONGOID_OPTIONS
      def max_pool_size
        (ENV['WORKAREA_MONGOID_MAX_POOL_SIZE'].presence || 100).to_i
      end
    end
  end
end
