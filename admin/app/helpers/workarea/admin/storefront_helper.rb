module Workarea
  module Admin
    module StorefrontHelper
      def storefront
        if Workarea::Storefront::Engine.mount_point == :storefront
          super
        else
          send(Workarea::Storefront::Engine.mount_point)
        end
      end
    end
  end
end
