/**
 * @namespace WORKAREA.tabs
 */
WORKAREA.registerModule('tabs', (function () {
    'use strict';

    var tabMenuTemplate = JST['workarea/admin/templates/tabs_menu'],

        initTabsUi = function ($ui) {
            $ui.tabs();
        },

        injectTabMenu = function ($ui, tabMenuData, tabIndex) {
            $ui.prepend(tabMenuTemplate({
                tabs: tabMenuData,
                tabIndex: tabIndex
            }));
        },

        setPanelIds = function ($panels, tabIds, tabIndex) {
            $panels.each(function (index, panel) {
                panel.id = tabIds[index] + '-tab-panel-' + tabIndex;
            });
        },

        getTabIds = function (tabName, index) {
            return WORKAREA.string.dasherize(tabName) + '-' + index;
        },

        getTabNames = function ($panels) {
            return $('> .tabs__heading', $panels).map(function (index, name) {
                return _.trim($(name).text());
            }).toArray();
        },

        setupTabsUi = function (index, element) {
            var $ui = $(element),
                $panels = $('> .tabs__panel', $ui),
                tabNames = getTabNames($panels),
                tabIds = _.map(tabNames, getTabIds),
                tabMenuData = _.zip(tabNames, tabIds);

            setPanelIds($panels, tabIds, index);
            injectTabMenu($ui, tabMenuData, index);
            initTabsUi($ui);
        },

        destroy = function() {
            $('.tabs__menu').remove();
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.tabs
         */
        init = function ($scope) {
            $('.tabs', $scope).each(setupTabsUi);
        };

        $(document).on('turbolinks:before-cache', destroy);

    return {
        init: init
    };
}()));
