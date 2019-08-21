/**
 * @namespace WORKAREA.filterDropdowns
 */
WORKAREA.registerModule('filterDropdowns', (function () {
    'use strict';

    var isDatepickerButton = function ($target) {
            return !_.isEmpty($target.closest('.ui-datepicker-header'));
        },

        isWithinDropdown = function ($target) {
            return !_.isEmpty($target.closest('.browsing-controls__filter--open'));
        },

        shouldntClose = function ($target) {
            return isDatepickerButton($target) || isWithinDropdown($target);
        },

        bindCloseAnywhere = function($filter) {
            $('body').one('click',function(event) {
                if(shouldntClose($(event.target))) { return; }

                closeDropdown($filter);
            });
        },

        openDropdown = function ($filter) {
            $filter.addClass('browsing-controls__filter--open');
            return $filter;
        },

        closeDropdown = function ($filter) {
            $filter.removeClass('browsing-controls__filter--open');
        },

        dropdownIsOpen = function($filter) {
            return $filter.hasClass('browsing-controls__filter--open');
        },

        closeAllDropdowns = function($filter) {
            var $controlGroup = $filter.closest('.browsing-controls');

            $('.browsing-controls__filter', $controlGroup)
            .removeClass('browsing-controls__filter--open');

            return $filter;
        },

        positionFilterDropdown = function ($filter, $button) {
            $filter
                .find('.browsing-controls__filter-dropdown')
                .position({
                    my: 'top',
                    at: 'bottom',
                    of: $button
                });
        },

        openFilter = _.flow(closeAllDropdowns, openDropdown, bindCloseAnywhere),

        handleFilterClick = function(event) {
            var $button = $(event.target),
                $filter = $button.closest('.browsing-controls__filter');

            //Prevent close anywhere code from propogating
            event.stopPropagation();

            if (dropdownIsOpen($filter)) {
                closeDropdown($filter);
            } else {
                openFilter($filter);
                positionFilterDropdown($filter, $button);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.filterDropdowns
         */
        init = function ($scope) {
            $('[data-filter-dropdown]', $scope).on('click', handleFilterClick);
        };

    return {
        init: init
    };
}()));
