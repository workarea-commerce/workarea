module Workarea
  module Storefront
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Storefront
    end
  end
end
