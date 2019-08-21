/**
 * @namespace WORKAREA.menuEditorLinks
 */
WORKAREA.registerModule('menuEditorLinks', (function () {
    'use strict';

    var appendNextList = function ($currentMenu, response) {
            var $newMenu = $(response);

            $currentMenu.nextAll('.menu-editor__menu').remove();
            $currentMenu.after($newMenu);

            WORKAREA.initModules($newMenu);
        },

        activateLink = function ($link) {
            $link
                .closest('.menu-editor__menu-list')
                    .find('.menu-editor__list-item--active')
                    .removeClass('menu-editor__list-item--active');

            $link
                .closest('.menu-editor__list-item')
                .addClass('menu-editor__list-item--active');
        },

        preserveActiveState = function (index, link) {
            var $menu = $(link).closest('.menu-editor__menu'),
                $nextMenu = $menu.next('.menu-editor__menu'),
                taxonId, nextMenuId;

            if (_.isEmpty($nextMenu)) { return; }

            taxonId = $(link).data('menuEditorLink').id;
            nextMenuId = $nextMenu.data('menuEditorParentId');

            if (taxonId !== nextMenuId) { return; }

            activateLink($(link));
        },

        handleLinkClick = function (event) {
            var $link = $(event.currentTarget),
                $currentMenu = $link.closest('.menu-editor__menu'),
                endpoint = $link.attr('href'),
                gettingNextList = $.get(endpoint);

            event.preventDefault();

            activateLink($link);

            gettingNextList.done(_.partial(appendNextList, $currentMenu));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.menuEditorLinks
         */
        init = function ($scope) {
            $('[data-menu-editor-link]', $scope)
            .on('click', handleLinkClick)
            .each(preserveActiveState);
        };

    return {
        init: init
    };
}()));
