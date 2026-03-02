module Workarea
  module Configuration
    module Mongoid
      extend self

      def load
        ::Mongoid::Config.load_configuration(
          clients: {
            default: MongoidClient.new.to_h,
            metrics: MongoidClient.new(:metrics).to_h
          }
        )

        # When running on Mongoid 8.x, apply load_defaults '7.5' to preserve legacy behavior
        # during the transition.  This ensures existing Workarea deployments upgrading from
        # Mongoid 7.4 do not experience silent behavior changes (e.g. broken_* flag defaults,
        # compare_time_by_ms, legacy_attributes, overwrite_chained_operators, etc.).
        # Operators should explicitly migrate to Mongoid 8 defaults after verifying their app.
        # NOTE: load_defaults was removed in Mongoid 9.x; guard the call accordingly.
        if ::Mongoid::VERSION.to_i >= 8
          ::Mongoid.load_defaults('7.5') if ::Mongoid.respond_to?(:load_defaults)
        end
      end

      def indexes_enforced?
        client = ::Mongoid::Clients.default.use('admin')
        result = client.command(getParameter: 1, notablescan: nil)
        client.close

        !!result.documents.first['notablescan']
      end
    end
  end
end
