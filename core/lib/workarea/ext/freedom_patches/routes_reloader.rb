module Rails
  class Application
    class RoutesReloader
      # HACK: Adds a rescue to the method that eager loads routes. This rescue
      # looks a the specific error the occurs when eager loading in development,
      # and forces the routes to reload again, clearing out load paths and
      # resetting everything -- essentially like restarting the application.
      # This allows us to avoid a constant need to stop and restart the server.
      # Only included in development environments.
      #
      def execute
        ret = updater.execute
        route_sets.each(&:eager_load!) if eager_load
        ret
      rescue ArgumentError => e
        raise e unless e.message == "unknown firstpos: NilClass"
        reload!
      end
    end
  end
end
