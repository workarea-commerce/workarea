module Workarea
  class Metadata::HomePage < Metadata
    # Provides a default value for use as the html page title of
    # the home page using the top selling menus.
    #
    # @example
    #   Shop Men's, Women's, Shoes, and Accessories
    #
    # @return [String]
    #
    def title
      [
        I18n.t('workarea.metadata.shop'),
        top_menus.map(&:name).to_sentence
      ].join(' ')
    end

    # Provides a default value for use as the html content meta
    # tag for the home page using the top selling menus
    #
    # @example
    #   Shop online for a great selection including Men's, Women's,
    #   Shoes, and Accesories
    #
    # @return [String]
    #
    def description
      [
        I18n.t(
          'workarea.metadata.shop_selection',
          name: Workarea.config.site_name
        ),
        top_menus.map(&:name).to_sentence
      ].join(' ')
    end

    private

    def top_menus
      @top_menus ||= Navigation::Menu.all.sort_by do |menu|
        Metrics::MenuByDay
          .by_menu(menu.id)
          .since(Workarea.config.sorting_score_ttl.ago)
          .score(:orders)
      end.reverse
    end
  end
end
