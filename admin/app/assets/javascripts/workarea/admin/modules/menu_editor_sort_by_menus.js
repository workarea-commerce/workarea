/**
 * Responsible for sorting navigation items when using the menu editor.
 *
 * @namespace WORKAREA.menuEditorSortByMenus
 */
WORKAREA.registerModule('menuEditorSortByMenus', (function () {
    'use strict';

    var replaceMenu = function ($menu, newMenu) {
            var $newMenu = $(newMenu);

            $menu.replaceWith($newMenu);

            WORKAREA.initModules($newMenu);
        },

        refreshItems = function ($select) {
            var $menu = $select.closest('.menu-editor__menu'),
                refreshUrl = $select.data('menuEditorSortByMenu'),
                refreshData = { sort_by: $select.val() };

            $.get(refreshUrl, refreshData)
            .done(_.partial(replaceMenu, $menu));
        },

        sortItems = function (event) {
            var $select = $(event.currentTarget),
                $form = $select.closest('form'),
                sortUrl = $form.attr('action');

            $.post(sortUrl, $form.serialize())
            .done(_.partial(refreshItems, $select));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.menuEditorSortByMenus
         */
        init = function ($scope) {
            $('[data-menu-editor-sort-by-menu]', $scope)
            .on('change', sortItems);
        };

    return {
        init: init
    };
}()));
