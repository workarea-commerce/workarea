module Workarea
  module MountPoint
    mattr_accessor :cache

    # Traverse Rack app-delegation wrappers (Constraints layers added by Rails router)
    # stopping as soon as we reach a Class (engine classes are Classes) or something
    # that does not respond to :app.  A depth ceiling prevents infinite loops.
    #
    # @param app   [Object] current app object to inspect
    # @param depth [Integer] recursion depth guard
    # @return [Object] the innermost non-wrapper app
    def self.unwrap_app(app, depth = 0)
      return app if depth > 10
      # Stop when we reach a Class — Rails engines ARE classes and respond to .app,
      # but we should not traverse into them.
      return app if app.is_a?(Class)
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
