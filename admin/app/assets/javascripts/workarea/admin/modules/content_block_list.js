/**
 * @namespace WORKAREA.contentBlockList
 */
WORKAREA.registerModule('contentBlockList', (function () {
    'use strict';

    var patchPosition = function ($form) {
            $.ajax($form.attr('action'), {
                method: $('[name="_method"]', $form).val(),
                data: $form.serialize()
            });
        },

        updateBlockOrder = function (event) {
            var $ui = $(event.target),
                $form = $ui.closest('form'),
                $names = $('.content-block-list__item', $ui);

            $names.each(function (index, name) {
                var $block = $($(name).data('blockId'));

                $('input', name).val(index);

                $block.data('blockOrder', index).css({ order: index });
            });

            return $form;
        },

        reorder = _.flow(
            updateBlockOrder,
            patchPosition,
            WORKAREA.addContentBlockButtons.reorder
        ),

        scrollBlockIntoView = function($block) {
            $('html, body').animate({
                scrollTop: (
                    window.sessionStorage.getItem('contentBlockScrollPosition')
                )
            }, 200);

            return $block;
        },

        saveBlockScrollPosition = function ($block) {
            window.sessionStorage.setItem(
                'contentBlockScrollPosition',
                Math.round($block.offset().top - 70)
            );

            return $block;
        },

        enableEditMode = _.flow(
            saveBlockScrollPosition,
            scrollBlockIntoView,
            WORKAREA.contentBlocks.activateBlock
        ),

        handleListItemclick = function(event) {
            var $blockButton = $(event.currentTarget).closest('.content-block-list__item'),
                $activeBlock = $($blockButton.data('blockId'));

            enableEditMode($activeBlock);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.contentBlockList
         */
        init = function ($scope) {
            $('.content-block-list', $scope)
            .on('click', '.content-block-list__name', handleListItemclick)
            .sortable({
                stop: reorder,
                handle: '.content-block-list__icon--move'
            });
        };

    $(window).on('turbolinks:before-visit', function () {
        window.sessionStorage.removeItem('contentBlockScrollPosition');
    });

    return {
        init: init,
        scrollBlockIntoView: scrollBlockIntoView,
        saveBlockScrollPosition: saveBlockScrollPosition
    };
}()));
