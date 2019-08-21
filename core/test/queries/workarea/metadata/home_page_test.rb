require 'test_helper'

module Workarea
  class Metadata
    class HomePageTest < TestCase
      setup :set_home_page
      setup :create_menus

      def set_home_page
        @home_page = create_content(name: 'home')
      end

      def create_menus
        4.times do |i|
          menu = create_menu(name: "Foo-#{i}")
          Metrics::MenuByDay.inc(key: { menu_id: menu.id }, orders: i)
        end
      end

      def test_title
        metadata = Metadata::HomePage.new(@home_page)
        assert_equal('Shop Foo-3, Foo-2, Foo-1, and Foo-0', metadata.title)
      end

      def test_description
        metadata = Metadata::HomePage.new(@home_page)
        assert_equal(
          "Shop #{Workarea.config.site_name} for a great selection including Foo-3, Foo-2, Foo-1, and Foo-0",
          metadata.description
        )
      end
    end
  end
end
