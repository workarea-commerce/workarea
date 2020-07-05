import uniq from "lodash.uniq"
import map from "lodash.map"
import groupBy from "lodash.groupby"
import ItemTemplate from "../templates/ui_menu_item.ejs"
import CategoryHeaderTemplate from "../templates/ui_menu_heading.ejs"
import $ from "jquery"
import "jquery-ui"

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
        'use strict'

        this._super()
        this.widget().menu(
            'option', 'items', '> :not(.ui-menu-heading)'
        )
    },

    _renderItem: function ($ul, item) {
        return $(ItemTemplate({ label: item.label, image: item.image })).appendTo($ul)
    },

    _renderMenu: function ($ul, items) {
        'use strict'

        var widget = this,
            categories = uniq(map(items, 'type')),
            itemsByCategory = groupBy(items, 'type'),
            renderCategoryItem = function (item) {
                widget._renderItemData($ul, item)
            },
            renderCategory = function (category) {
                $ul.append(CategoryHeaderTemplate({
                    categoryName: category
                }))

                itemsByCategory[category].forEach(renderCategoryItem)
            }

        categories.forEach(renderCategory)
    }
})
