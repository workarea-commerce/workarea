/**
 * @external jQuery
 */

/**
 * @method
 * @name categorizedAutocomplete
 * @memberof external:jQuery
 */
$.widget('workarea.categorizedAutocomplete', $.ui.autocomplete, {
    _create: function () {
        'use strict';

        this._super();

        this.widget().menu(
            'option', 'items', '> :not(.ui-menu-heading)'
        );
    },

    _renderItem: function ($ul, item) {
        'use strict';

        var itemTemplate = JST['workarea/admin/templates/ui_menu_item'];

        return $(itemTemplate({ label: item.label, image: item.image })).appendTo($ul);
    },

    _renderMenu: function ($ul, items) {
        'use strict';

        var widget = this,
            categories = _.uniq(_.map(items, 'type')),
            itemsByCategory = _.groupBy(items, 'type'),
            categoryHeaderTemplate = JST['workarea/admin/templates/ui_menu_heading'],

            renderCategoryItem = function (item) {
                widget._renderItemData($ul, item);
            },

            renderCategory = function (category) {
                $ul.append(categoryHeaderTemplate({
                    categoryName: category
                }));

                _.forEach(
                    itemsByCategory[category], renderCategoryItem
                );
            };

        _.forEach(categories, renderCategory);
    }
});
