/**
 * @namespace WORKAREA.sortNavigationMenus
 */
WORKAREA.registerModule('navigationMenuSortables', (function () {
    'use strict';

    var findMenuPositions = function (event) {
            var result = {},
                $menus = $('[data-sort-navigation-menu-id]', event.target);

            $menus.each(function (index, menu) {
                var id = $(menu).data('sortNavigationMenuId');

                if (id) {
                    result['positions[' + id + ']'] = index;
                }
            });

            return result;
        },

        saveSort = function (event) {
            $.post(
                WORKAREA.routes.admin.moveNavigationMenusPath(),
                findMenuPositions(event)
            );
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.sortNavigationMenus
         */
        init = function ($scope) {
            $('[data-sort-navigation-menu]', $scope).sortable({
                stop: saveSort,
            });
        };

    return {
        init: init
    };
}()));

