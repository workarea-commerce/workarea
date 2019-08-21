module Workarea
  module Monitoring
    class LoadBalancingCheck
      def check
        [true, 'Up']
      end
    end
  end
end
