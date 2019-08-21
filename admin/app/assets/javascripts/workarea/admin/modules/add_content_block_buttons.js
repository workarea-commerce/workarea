/**
 * @namespace WORKAREA.addContentBlockButtons
 */
WORKAREA.registerModule('addContentBlockButtons', (function () {
    'use strict';

    var loadingIndicator = JST['workarea/admin/templates/loading'],

        injectBlocks = function (response) {
            var $response = $(response);

            $('#takeover .takeover__content').empty().append($response);

            // in order for tooltipster to find the proper IDs within the
            // content block takeover, modules must be initialized _after_
            // the DOM is appended.
            WORKAREA.initModules($response);
        },

        fetchBlocks = function (button) {
            $.get(button.href).done(injectBlocks);
        },

        openLoadingTakeover = function (button) {
            WORKAREA.takeover.open(loadingIndicator({
                cssModifiers: 'loading--large loading--fill-parent'
            }));

            return button;
        },

        preventClick = function (event) {
            event.preventDefault();
            return event.currentTarget;
        },

        loadBlocks = _.flow(preventClick, openLoadingTakeover, fetchBlocks),

        /**
         * [reorder description]
         * @return {[type]} [description]
         */
        reorder = function () {
            var $blocks = $('#content_editor .content-block');

            $blocks.each(function (blockIndex, block) {
                var $buttons = $('[data-add-content-block-button]', block);

                $buttons.each(function (buttonIndex, button) {
                    var newIndex = $(block).data('blockOrder') + buttonIndex;

                    button.href = WORKAREA.url.updateParams(button.href, {'position': newIndex});
                });
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.addContentBlockButtons
         */
        init = function ($scope) {
            $('[data-add-content-block-button]', $scope)
            .on('click', loadBlocks);
        };

    return {
        init: init,
        reorder: reorder
    };
}()));
