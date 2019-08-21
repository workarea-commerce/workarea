module Workarea
  module Monitoring
    class MongoidCheck

      def check
        status = database_up?
        [status, status ? 'Up' : 'Down']
      end

      private

      def database_up?
        Mongoid::Clients
          .with_name('default')
          .collections
          .find
          .present?
      rescue
        false
      end
    end
  end
end
