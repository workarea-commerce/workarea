/**
 * @namespace WORKAREA.disablePublishNow
 */
WORKAREA.registerModule('disablePublishNow', (function () {
    'use strict';

    var getConfig = function ($button) {
            var $parent = $button.closest('form');
            return _.assign({}, WORKAREA.config.tooltipster, {
                content : $('[data-disable-publish-now-warning]', $parent),
                contentCloning: true,
                side: 'top'
            });
        },

        enableTooltip = function($button) {
            if ($button.hasClass('tooltipstered')) {
                $button.tooltipster('enable');
            } else {
                $button.tooltipster(getConfig($button));
            }

            $button.tooltipster('open');
        },

        disableTooltip = function($button) {
            if ( ! $button.hasClass('tooltipstered')) { return; }

            $button
            .tooltipster('disable')
            .tooltipster('close');
        },

        checkPublishOption = function($option, event) {
            var $select = $(event.target),
                $button = $select.closest('form').find('[type="submit"]');

            if ($select.val() === $option.attr('value') && $button.is(':visible')) {
                $button.attr('disabled', 'disabled');
                enableTooltip($button);
            } else {
                $button.removeAttr('disabled');
                disableTooltip($button);
            }
        },

        toggleTooltips = function($options) {
            _.forEach($options, function(option) {
                var $option = $(option);
                checkPublishOption($option, { target: $option.closest('select') });
            });
        },

        handleContentEditorForms = function(event) {
            var $options = $(event.target).find('[data-disable-publish-now]');
            toggleTooltips($options);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.disablePublishNow
         */
        init = function ($scope) {
            var $option = $('[data-disable-publish-now]', $scope);

            $option
                .parent('select')
                .on('change', _.partial(checkPublishOption, $option));

            toggleTooltips($option);

            $('.content-editor', $scope)
            .on('close:contentEditorAside open:contentEditorAside', handleContentEditorForms);
        };

    return {
        init: init
    };
}()));
