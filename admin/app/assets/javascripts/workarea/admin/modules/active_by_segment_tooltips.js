/**
 * @namespace WORKAREA.activeBySegmentTooltips
 */
WORKAREA.registerModule('activeBySegmentTooltips', (function () {
    'use strict';

    var hiddenInput = JST['workarea/core/templates/hidden_input'],

        getSelectedOptionText = function ($select) {
            return $select.find('option:selected').map(function (_i, option) {
                return $.trim($(option).text());
            }).toArray();
        },

        updateMessages = function ($link, $content) {
            var $message = $link.find('.active-field__segments-message'),
                names = getSelectedOptionText($content.find('select')),
                text = I18n.t('workarea.admin.shared.active_field.by_segment', {
                    count: names.length,
                    name: names[0],
                    more_count: names.length - 1
                });

            if (_.isEmpty(names)) {
                $message.html($('<span />').text(text));
            } else {
                $message.html($('<strong />').text(text));
            }
        },

        buildInput = function (name, value) {
            var input = hiddenInput({ name: name, value: value });
            return $(input).data('activeBySegmentInput', true);
        },

        addHiddenInputs = function ($form, $content) {
            $content
                .find('select')
                .each(function (index, select) {
                    var $select = $(select);

                    if (_.isEmpty($select.val())) {
                        $form.append(buildInput(select.name, ''));
                    } else {
                        _.forEach($select.val(), function (value) {
                            $form.append(buildInput(select.name, value));
                        });
                    }
                });
        },

        removeHiddenInputs = function ($form) {
            $form
                .find('[type=hidden]')
                    .filter(function (index, input) {
                        return $(input).data('activeBySegmentInput') === true;
                    })
                    .remove();
        },

        getConfig = function (trigger) {
            var $link = $(trigger),
                $form = $link.closest('form'),
                $content = $(trigger.hash);

            return _.assign({}, WORKAREA.config.tooltipster, {
                trigger: 'click',
                interactive: true,
                content: $content,
                functionAfter: function (instance) {
                    var $tooltipContent = instance.content();
                    removeHiddenInputs($form);
                    addHiddenInputs($form, $tooltipContent);
                    updateMessages($link, $tooltipContent);
                }
            });
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.activeBySegmentTooltips
         */
        init = function ($scope) {
            $('[data-active-by-segment-tooltip]', $scope)
            .on('click', function (event) {
                event.preventDefault();
            })
            .each(function(index, trigger) {
                $(trigger).tooltipster(getConfig(trigger));
            });
        };

    return {
        init: init
    };
}()));
