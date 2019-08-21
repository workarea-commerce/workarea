/**
 * Define a `data-jump-to-menu` attribute on a container. This module will loop
 * over any child with a `data-jump-to-menu-heading` attribute and use its
 * numeric value as a way to build out a navigation UI that is stuck to the
 * bottom right of the page. Each `data-jump-to-menu-heading` must also have a
 * unique ID attribute value applied to the element in order to construct the
 * links appropriately.
 *
 * @namespace WORKAREA.jumpToMenu
 */
WORKAREA.registerModule('jumpToMenu', (function () {
    'use strict';

    var menu = JST['workarea/admin/templates/jump_to_menu'],

        scrollToAnchor = function (event) {
            event.preventDefault();

            $(window).scrollTop(
                $(event.target.hash).offset().top - $('#header').height() - 8
            );
        },

        buildMenu = function (container) {
            var $headings = $('[data-jump-to-menu-heading]', container),
                items = $headings.map(function (index, heading) {
                    return {
                        anchor: heading.id,
                        name: $(heading).text().trim(),
                        level: $(heading).data('jumpToMenuHeading')
                    };
                }).toArray();

            if (_.isEmpty(items)) { return; }

            return $(menu({ items: items }));
        },

        setup = function (index, container) {
            var $menu;

            if ( ! _.isEmpty($('.jump-to-menu'))) {
                window.console.warn(
                    'WORKAREA.jumpToMenu.init: you may only have one Jump-To ' +
                    'Menu on the page at a time.'
                );

                return;
            }

            $menu = buildMenu(container);

            $menu.on('click', 'a', scrollToAnchor);

            if ( ! _.isEmpty($('.workflow-bar'))) {
                $menu.addClass('jump-to-menu--with-workflow-bar');
            }

            $('body').append($menu);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.jumpToMenu
         */
        init = function ($scope) {
            $('[data-jump-to-menu]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
