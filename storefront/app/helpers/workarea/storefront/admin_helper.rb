module Workarea
  module Storefront
    module AdminHelper
      def admin
        if Workarea::Admin::Engine.mount_point == :admin
          super
        else
          send(Workarea::Admin::Engine.mount_point)
        end
      end
    end
  end
end
