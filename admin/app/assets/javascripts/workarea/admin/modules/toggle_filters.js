/**
 * @namespace WORKAREA.toggleFilters
 */
WORKAREA.registerModule('toggleFilters', (function () {
    'use strict';

    var updateButtonText = function($button) {
            var $browsingControls = $button.closest('.browsing-controls');

            if ($browsingControls.hasClass('browsing-controls--filters-displayed')) {
                $button.text(I18n.t('workarea.admin.js.toggle_filters.hide_filters'));
            } else {
                $button.text(I18n.t('workarea.admin.js.toggle_filters.show_filters'));
            }
        },

        toggleFilterDisplay = function($button) {
            $button.closest('.browsing-controls').toggleClass('browsing-controls--filters-displayed');

            return $button;
        },

        toggleFilters = _.flow(toggleFilterDisplay, updateButtonText),

        handleClick = function (event) {
            var $button = $(event.currentTarget);

            toggleFilters($button);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.toggleFilters
         */
        init = function ($scope) {
            $('[data-toggle-filters]', $scope).on('click', handleClick);
        };

    return {
        init: init
    };
}()));
