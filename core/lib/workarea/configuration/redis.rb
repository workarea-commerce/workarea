module Workarea
  module Configuration
    class Redis
      DEFAULT = { host: 'localhost', port: 6379, db: 0, scheme: 'redis' }.freeze

      class << self
        # Used for Sidekiq and Predictor
        def persistent
          @persistent ||= new(find_config(:redis))
        end

        # Use this for Rails.cache and Rack::Cache config or other ephemeral
        # Redis needs.
        #
        # Falls back to the persistent config if there is no config for Redis
        # cache.
        #
        # Note that this isn't applied automatically - application config
        # can/should use Workarea::Configuration::Redis.cache if caching is being
        # set up with Redis.
        #
        def cache
          @cache ||=
            begin
              config = find_config(:redis_cache)
              config == DEFAULT ? persistent : new(config)
            end
        end

        # Looks in order at Workarea.config, Rails secrets, ENV. Recommended to
        # config both WORKAREA_REDIS_* keys and WORKAREA_REDIS_CACHE_* keys with
        # separate DBs or separate servers.
        #
        def find_config(name)
          config_slug = name.to_s.underscore.downcase
          from_config = Workarea.config[config_slug].presence ||
                          Rails.application.secrets[config_slug]

          return from_config if from_config.present?

          env_slug = name.to_s.underscore.upcase
          scheme = ENV["WORKAREA_#{env_slug}_SCHEME"].presence || DEFAULT[:scheme]

          {
            scheme: scheme,
            host: ENV["WORKAREA_#{env_slug}_HOST"].presence || DEFAULT[:host],
            port: ENV["WORKAREA_#{env_slug}_PORT"].presence || DEFAULT[:port],
            db: ENV["WORKAREA_#{env_slug}_DB"].presence || DEFAULT[:db],
            password: ENV["WORKAREA_#{env_slug}_PASSWORD"].presence,
            ssl: scheme == 'rediss' ? true : false
          }
        end
      end

      attr_reader :config
      alias_method :to_h, :config

      def initialize(config)
        @config = config.to_h.deep_symbolize_keys
      end

      def scheme
        @config[:scheme]
      end

      def ssl
        @config[:ssl]
      end

      def host
        @config[:host]
      end

      def password
        @config[:password]
      end

      def port
        @config[:port]
      end

      def db
        @config[:db]
      end

      def to_url
        base = "#{scheme}://"
        base << "admin:#{password}@" if password.present?
        base << "#{host}"
        base << ":#{port}" if port.present?
        base << "/#{db}" if db.present?
        base
      end
    end
  end
end
