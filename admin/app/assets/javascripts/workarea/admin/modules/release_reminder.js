/**
 * @namespace WORKAREA.releaseReminder
 */
WORKAREA.registerModule('releaseReminder', (function () {
    'use strict';

    var yes = function (event) {
            event.preventDefault();

            $('.release-select--emphasize')
            .removeClass('release-select--emphasize');

            $.post(WORKAREA.routes.admin.touchReleaseSessionPath());
        },

        no = function (event) {
            event.preventDefault();

            if (WORKAREA.environment.isTest) { return; }

            var form = JST['workarea/admin/templates/release_select_form']({
                url: WORKAREA.routes.admin.releaseSessionPath(),
                csrfParam: $('meta[name=csrf-param]').attr('content'),
                csrfToken: $('meta[name=csrf-token]').attr('content'),
                releaseId: ''
            });

            $(form).hide().appendTo('body').submit();
        },

        onTooltipReady = function (instance, helper) {
            fixTooltipHeight(helper.tooltip);
            bindTooltipActions(helper.tooltip);
        },

        fixTooltipHeight = function (tooltip) {
            $(tooltip).height('auto');
        },

        bindTooltipActions = function (tooltip) {
            $('[data-release-reminder-no]', tooltip).on('click', _.flow(closeTooltip, no));
            $('[data-release-reminder-yes]', tooltip).on('click', _.flow(closeTooltip, yes));
        },

        closeTooltip = function (event) {
            $(event.currentTarget).closest('.tooltipster-base').remove();
            return event;
        },

        positionTooltip = function (instance, helper, position) {
            return _.merge({}, position, {
                side: 'bottom',
                size: {
                    width: helper.geo.origin.size.width
                },
                coord: {
                    top: helper.geo.origin.windowOffset.bottom,
                    left: helper.geo.origin.windowOffset.left
                }
            });
        },

        openTooltip = function (instance) {
            instance.open();
        },

        getTooltipsterConfig = function () {
            return _.merge({}, {
                animation: 'fall',
                content: $('#release-select-reminder'),
                contentAsHTML: true,
                interactive: true,
                trigger: 'custom',
                functionInit: openTooltip,
                functionPosition: positionTooltip,
                functionReady: onTooltipReady
            }, WORKAREA.config.tooltipster);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.releaseReminder
         */
        init = function ($scope) {
            $('.release-select--emphasize', $scope)
                .has('.tooltip-content')
                .find('.release-select__container')
                .tooltipster(getTooltipsterConfig());

        };

    return {
        init: init
    };
}()));
