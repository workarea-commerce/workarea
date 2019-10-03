/**
 * @namespace WORKAREA.activeBySegmentTooltips
 */
WORKAREA.registerModule('activeBySegmentTooltips', (function () {
    'use strict';

    var initTooltip = function (index, trigger) {
            var $link = $(trigger),
                $form = $link.closest('form');

            $link.tooltipster(
                _.assign({}, WORKAREA.config.tooltipster, {
                    interactive: true,
                    content: $($link.attr('href')),
                    functionAfter: function(instance) {
                        var $tooltip = instance.content();
                        addHiddenInputs($form, $tooltip);
                        updateMessages($link, $tooltip);
                    }
                })
            );
        },

        addHiddenInputs = function ($form, $tooltip) {
            $form.remove('input[type=hidden]:data(activeBySegmentInput)');

            $tooltip.find('select').each(function (i, select) {
                var $select = $(select),
                    $input = null;

                if (!$select.val().length) {
                    $input = $('<input/>')
                    .attr({ type: 'hidden', name: $select.attr('name'), value: '' })
                    .data('activeBySegmentInput', true);

                    $form.append($input);
                } else {
                    $select.val().forEach(function(value) {
                        $input = $('<input/>')
                        .attr({ type: 'hidden', name: $select.attr('name'), value: value })
                        .data('activeBySegmentInput', true);

                        $form.append($input);
                    });
                }
            });
        },

        updateMessages = function ($link, $tooltip) {
            var $target = $link.find('.active-field__segments-message'),
                names = [],
                text = null;

            $tooltip.find('select').each(function (i, select) {
                var $select = $(select),
                    $options = $select.find('option:selected');

                $options.each(function(i, option) { names.push($(option).text()); });
            });

            text = I18n.t(
                'workarea.admin.shared.active_field.by_segment',
                { count: names.length, names: names.join(', ') }
            );

            if (names.length) {
                $target.html($('<strong/>').text(text));
            } else {
                $target.html($('<span/>').text(text));
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.activeBySegmentTooltips
         */
        init = function ($scope) {
            $('[data-active-by-segment-tooltip]', $scope).each(initTooltip);
        };

    return {
        init: init
    };
}()));
