module Workarea
  module Admin
    class Engine < ::Rails::Engine
      include Workarea::Plugin
      isolate_namespace Workarea::Admin
    end
  end
end
