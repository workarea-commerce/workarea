require 'test_helper'

module Workarea
  module Navigation
    class MenuTest < TestCase
      def test_active
        menu = create_menu(active: false)
        refute(menu.active?)

        menu.update_attributes!(active: true)
        assert(menu.active?)

        page = create_page(active: false)
        taxon = create_taxon(navigable: page)
        menu.update_attributes!(taxon: taxon)
        refute(menu.active?)

        page.update_attributes!(active: true)
        assert(menu.active?)
      end
    end
  end
end
