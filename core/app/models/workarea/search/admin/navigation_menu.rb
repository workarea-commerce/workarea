module Workarea
  module Search
    class Admin
      class NavigationMenu < Search::Admin
        include Admin::Releasable

        def search_text
          [model.id, model.name]
        end
      end
    end
  end
end
