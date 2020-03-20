/**
 * @namespace WORKAREA.remoteSelects
 */
WORKAREA.registerModule('remoteSelects', (function () {
    'use strict';

    var injectHiddenInput = function (index, select) {
            // allows select[multiple=true] elements to post empty values
            if ( ! $(select).is('[multiple]')) { return; }

            $(select).before(function () {
                return JST['workarea/core/templates/hidden_input']({
                    name: select.name,
                    value: ''
                });
            });
        },

        formatOption = function (item) {
            return $(JST['workarea/admin/templates/remote_select_insight']({
                text: item.text,
                sparkline_data: item.sparkline_data,
                top: item.top,
                trending: item.trending,
                title: item.title
            }));
        },

        getConfig = function (select) {
            var settings = _.assign({}, WORKAREA.config.remoteSelects,
                    $(select).data('remoteSelect').options
                );


            settings.ajax.url = $(select).data('remoteSelect').source;
            settings.templateResult = formatOption;

            if (settings.dropdownParent) {
                settings.dropdownParent = $(settings.dropdownParent);
            }

            return settings;
        },

        reorderSelectOptions = function ($choiceUI, select) {
            var $choices = $choiceUI.find('.select2-selection__choice');

            $choices.each(function (index, choice) {
                $(select).append($(choice).data('remoteSelectOption'));
            });

            $choiceUI.trigger('change');
        },

        associateSelectOptions = function ($choiceUI, select) {
            var $choices = $choiceUI.find('.select2-selection__choice'),
                $selectOptions = $(select).find('option'),
                $options = $selectOptions.filter(function (index, option) {
                    return ! _.isEmpty(option.value);
                });

            $options.each(function (index, option) {
                $choices.eq(index).data('remoteSelectOption', option);
            });
        },

        initSortable = function (select) {
            var $select2 = $(select).next('.select2'),
                $choiceUI = $select2.find('.select2-selection__rendered');

            $choiceUI.sortable({
                containment: 'parent',
                tolerance: 'pointer',
                cursor: 'move',
                start: _.partial(associateSelectOptions, $choiceUI, select),
                stop: _.partial(reorderSelectOptions, $choiceUI, select)
            });
        },

        initSelect2 = function (index, select) {
            var config = getConfig(select);

            injectHiddenInput(index, select);
            $(select).select2(config);

            if (config.autoSubmit) {
                $(select).on('select2:select', function () {
                    $(this).parents('form').submit();
                });
            }

            if ($(select).is('[multiple]')) {
                initSortable(select);
            }
        },

        /**
         * Destroy all select2 elements before page is reloaded. Called
         * before turbolinks reloads the page.
         *
         * @method
         * @name destroy
         * @memberof WORKAREA.remoteSelects
         */
        destroy = function(event) {
            $('[data-remote-select]', event.currentTarget)
            .select2('destroy');
        },

        /**
         * Initialize all uninitialized select2 elements.
         *
         * @method
         * @name init
         * @memberof WORKAREA.remoteSelects
         */
        init = function ($scope) {
            $('[data-remote-select]', $scope)
                .not('.select2-hidden-accessibility')
                .each(initSelect2);
        };

    $(document).on('turbolinks:before-cache', destroy);

    return {
        init: init
    };
}()));
