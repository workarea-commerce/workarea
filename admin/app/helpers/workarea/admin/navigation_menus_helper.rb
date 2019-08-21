module Workarea
  module Admin
    module NavigationMenusHelper
      def navigation_menu_classes(menu, active_menu)
        classes = []
        classes << 'navigation-builder__node--selected' if menu == active_menu
        classes << 'navigation-builder__node--inactive' unless menu.active?
        classes.join(' ')
      end
    end
  end
end
