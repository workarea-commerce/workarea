module Workarea
  module Testing
    module Indexes
      def self.enable_enforcing!
        set(1)
      end

      def self.disable_enforcing!
        set(0)
      end

      def self.set(value)
        servers = Mongoid::Clients.default.cluster.servers
        addresses = servers.map(&:address).map(&:to_s)

        client = Mongo::Client.new(addresses, database: 'admin')
        client.command(setParameter: 1, notablescan: value)
        client.close
      end
    end
  end
end
