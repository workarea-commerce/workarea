module Workarea
  module MountPoint
    mattr_accessor :cache

    # Traverse the app-delegation chain to find the underlying app class.
    # In Rails 7, mounted engines are wrapped in one or more
    # +ActionDispatch::Routing::Mapper::Constraints+ layers.  Plain routes use
    # +ActionDispatch::Routing::RouteSet::Dispatcher+, which does not respond to
    # +#app+, so we must guard before each step.
    #
    # A depth ceiling prevents infinite loops in degenerate cases (e.g., a
    # Rack app whose +#app+ method returns +self+).
    #
    # @param app [Object] the route app (or a wrapper around it)
    # @param depth [Integer] recursion depth guard (stops at 10)
    # @return [Object] the innermost app object
    def self.unwrap_app(app, depth = 0)
      return app if depth > 10
      app.respond_to?(:app) ? unwrap_app(app.app, depth + 1) : app
    end

    # Find the named-route key for the engine class *klass*.
    #
    # The result is memoized in +.cache+.  The cache is intentionally keyed by
    # class object so that route reloads in development (which rebuild the
    # engine class) automatically miss the cache.
    #
    # @param klass [Class] the Rails engine class to locate
    # @return [Symbol, nil] the named-route key, e.g. +:storefront+, or +nil+
    def self.find(klass)
      self.cache ||= {}
      return cache[klass] if cache.key?(klass)

      result = nil
      Rails.application.routes.named_routes.each do |name, route|
        begin
          if unwrap_app(route.app) == klass
            result = name
            break
          end
        rescue StandardError
          next
        end
      end

      cache[klass] = result
    end

    def mount_point
      Workarea::MountPoint.find(self)
    end

    def mounted?
      mount_point.present?
    end

    def mount_path
      return nil unless mounted?
      routes.url_helpers.root_path
    end
  end
end
