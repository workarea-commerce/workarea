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
