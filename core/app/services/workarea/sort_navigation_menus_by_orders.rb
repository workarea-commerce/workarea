module Workarea
  class SortNavigationMenusByOrders
    def self.perform
      new.perform
    end

    def perform
      sorted_menus.each_with_index { |m, i| m.set(position: i) }
    end

    def menus
      @menus ||= Navigation::Menu.all.to_a
    end

    def sorted_menus
      @sorted_menus ||= menus.sort_by { |m| scores[m] || 999 }.reverse
    end

    private

    def scores
      menus.reduce({}) do |memo, menu|
        memo.merge(
          menu => Metrics::MenuByDay
            .by_menu(menu.id)
            .since(Workarea.config.sorting_score_ttl.ago)
            .score(:orders)
        )
      end
    end
  end
end
