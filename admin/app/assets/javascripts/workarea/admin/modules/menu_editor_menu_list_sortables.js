/**
 * @namespace WORKAREA.menuEditorMenuListSortables
 */
WORKAREA.registerModule('menuEditorMenuListSortables', (function () {
    'use strict';

    var patchMenu = function (endpoint, otherId, direction) {
            $.ajax({
                url: endpoint,
                type: 'POST',
                data: {
                    _method: 'PATCH',
                    other_id: otherId,
                    direction: direction
                }
            });
        },

        reorder = function ($menu) {
            var $addbuttons = $('.menu-editor__add-item-button', $menu),
                parentId = $menu.data('menuEditorParentId');

            $addbuttons.each(function (index, button) {
                button.href = WORKAREA.url.updateParams(window.location.href, {
                    'position': index,
                    'parent_id': parentId
                });
            });
        },

        isPlaceholder = function ($item) {
            return $item.is('.menu-editor__list-item--placeholder');
        },

        addToParent = function ($prevItem, $nextItem) {
            return (_.isEmpty($prevItem) || _.isEmpty($nextItem)) &&
                 (isPlaceholder($prevItem) || isPlaceholder($nextItem));
        },

        getItemId = function ($item) {
            return $('[data-menu-editor-link]', $item)
                   .data('menuEditorLink')
                   .id;
        },

        showPlaceholder = function (event) {
            var $items = $('.menu-editor__list-item', event.target),
                $placeholder = $items.filter(
                    '.menu-editor__list-item--placeholder'
                );

            if ($items.length > 1) { return; }
            if ( ! $items.is($placeholder)) { return; }

            $placeholder.removeClass('hidden');
        },

        updateMenu = function (event, ui) {
            var $item = ui.item,
                $link = $('[data-menu-editor-link]', $item),
                $nextItem = $item.next('.menu-editor__list-item'),
                $prevItem = $item.prev('.menu-editor__list-item'),
                $destination = $(event.toElement).closest('.menu-editor__menu'),
                endpoint = $link.data('menuEditorLink').moveUrl;

            if (addToParent($prevItem, $nextItem)) {
                patchMenu(endpoint, $destination.data('menuEditorParentId'));
            } else if (_.isEmpty($prevItem)) {
                patchMenu(endpoint, getItemId($nextItem), 'above');
            } else {
                patchMenu(endpoint, getItemId($prevItem), 'below');
            }

            reorder($destination);

            return event;
        },

        handleSortableStop = _.flowRight(showPlaceholder, updateMenu),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.menuEditorMenuListSortables
         */
        init = function ($scope) {
            var $menuList = $('.menu-editor__menu-list', $scope);

            if ( ! _.isEmpty($menuList.closest('.content-editor'))) { return; }

            $menuList.sortable({
                connectWith: '.menu-editor__menu-list',
                cancel: [
                    '.menu-editor__list-item--active',
                    '.menu-editor__list-item--placeholder'
                ].join(','),
                items: '> .menu-editor__list-item',
                stop: handleSortableStop,
                scrollSensitivity: 64 // matches `$global-header-height` in css
            });
        };

    return {
        init: init,
        addToParent: addToParent
    };
}()));
