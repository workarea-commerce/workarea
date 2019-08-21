/**
 * @namespace WORKAREA.mobileFilterButtons
 *
 * A clone of WORKAREA.mobileNavButton
 */
WORKAREA.registerModule('mobileFilterButtons', (function () {
    'use strict';

    var closeButton = JST['workarea/storefront/templates/mobile_filters_nav_close_button'],

        deactivate = function ($nav) {
            $nav.removeClass('mobile-filters-nav--active');
        },

        activate = function ($nav) {
            $nav.addClass('mobile-filters-nav--active');
        },

        close = function ($nav, event) {
            event.preventDefault();
            deactivate($nav);
        },

        addCloseButton = function ($nav) {
            var $button = $(closeButton({
                content: I18n.t('workarea.storefront.products.filter_nav_close_button')
            }));

            $button.on('click', _.partial(close, $nav));

            $nav.prepend($button);
        },

        inject = function () {
            var $nav = $('<div class="mobile-filters-nav" id="mobile_filters_nav" />'),
                $content = $('#aside-content').clone(true);

            $nav.append($content);

            activate($nav);
            addCloseButton($nav);

            WORKAREA.initModules($nav);

            $('body').append($nav);
        },

        openMobileFilters = function (event) {
            event.preventDefault();

            if (_.isEmpty($('#mobile_filters_nav'))) {
                inject(event.target);
            } else {
                activate($('#mobile_filters_nav'));
            }
        },

        testBodyClick = function (event) {
            var $target = $(event.target),
                $nav = $('#mobile_filters_nav'),
                $navButton = $('[data-mobile-filter-button]'),

                navIsActive = $nav.hasClass('mobile-filters-nav--active'),
                clickIsOutsideNav = _.isEmpty($target.closest($nav).addBack($nav)),
                clickIsNavButton = ! _.isEmpty($target.closest($navButton).addBack($navButton));

            if (navIsActive && clickIsOutsideNav && ( ! clickIsNavButton)) {
                close($nav, event);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.mobileFilterButtons
         */
        init = function ($scope) {
            $('[data-mobile-filter-button]', $scope)
            .on('click', openMobileFilters);
        };

    $('body').on('click.mobileFilterButtons', testBodyClick);

    return {
        init: init
    };
}()));
