/**
 * Displays a menu within a tooltip on click
 *
 * @namespace WORKAREA.tooltips
 */
WORKAREA.registerModule('tooltips', (function () {
    'use strict';

    /**
     * Tooltipster repositioning callback
     * Activated by passing data menu: true to the tooltip data attr
     *
     * @param  {Object} instance Tooltipster Instance
     * @param  {Object} helper   Tooltipster Helper
     * @param  {Object} position Tooltipster positioning data
     * @return {Object}          Modified Tooltipster positioning data
     */
    var positionTooltip = function (instance, helper, position) {
            var origin = helper.geo.origin,
                menuWidth = position.size.width,
                scrollTop = helper.geo.window.scroll.top,
                windowWidth = helper.geo.window.size.width;

            position.coord.top = origin.offset.bottom - scrollTop;
            position.coord.left = origin.offset.left;

            if (origin.offset.left + menuWidth > windowWidth) {
                position.coord.left = windowWidth - menuWidth;
            }

            return position;
        },

        wrapRequestedContent = function(response) {
            return $(response).wrap("<div class='tooltip-content'></div>").parent();
        },

        requestContent = function (instance, helper) {
            var contentURL = $(helper.origin).data('tooltip').content_url;

            $.get(contentURL)
            .done(function (response) {
                var $content = wrapRequestedContent(response);

                WORKAREA.initModules($content);
                instance.content($content);
            });
        },

        tooltipState = function($trigger) {
            return $trigger.tooltipster('status').state;
        },

        // If the options contains a content_id selector use that
        // Otherwise If the trigger is a link with href use that to populate tooltip
        // If neither are present, throw an error.
        getContent = function(trigger, options) {
            var $content;

            if (!_.isEmpty(options.content)) {
                $content = $('<div />').html(options.content);
            } else if (!_.isEmpty(options.content_id)) {
                $content = $(options.content_id);
            } else if(!_.isEmpty($(trigger).attr('href'))) {
                $content = $($(trigger).attr('href'));
            } else {
                $content = $('<div />');
            }

            // Prevent interactive UIs within a tooltip from accidentally
            // closing the tooltip. A good example of this would be jQuery UI
            // Datepicker or Datetimepicker being embedded in a tooltip.
            if (options.interactive && options.trigger === 'click') {
                $content.on('click', function (event) {
                    event.stopPropagation();
                });
            }

            return $content;
        },

        customTriggerToggle = function ($trigger) {
            var state = tooltipState($trigger);

            if (state === 'closed') {
                $trigger.tooltipster('open');
            } else {
                $trigger.tooltipster('close');
            }
        },

        handleClickEvent = function(event) {
            var $trigger = $(event.currentTarget),
                options = $trigger.data('tooltip');

            if (!options.allow_click) {
                event.preventDefault();
            }

            if (options.trigger === 'custom') {
                customTriggerToggle($trigger);
            }
        },

        getConfig = function (options) {
            return _.assign({}, WORKAREA.config.tooltipster, options,{
                functionPosition: options.menu ? positionTooltip : null,
                functionBefore: options.content ? requestContent : null
            });
        },

        initTooltip = function (index, trigger) {
            var options = $(trigger).data('tooltip'),
                config = getConfig(options);

            config.content = getContent(trigger, options);

            $(trigger).tooltipster(config);
        },

        /**
         * Expects to find a `data-tooltip` attribute within a given
         * `$scope`. The attribute's value should be a JSON object
         * contentId is a required setting and should be a CSS selector representing
         * an on-page, unique ID. The contents of this selector represents the
         * menu to display.
         *
         * @method
         * @name init
         * @memberof WORKAREA.tooltips
         */
        init = function ($scope) {
            $('[data-tooltip]', $scope)
            .each(initTooltip)
            .on('click', handleClickEvent);
        };

    return {
        init: init,
        positionTooltip: positionTooltip
    };
}()));

