/**
 * @namespace WORKAREA.contentPreview
 */
WORKAREA.registerModule('contentPreview', (function () {
    'use strict';

    var resizeIframe = function($contentPreview, breakpoint) {
            var $iframe = $('.content-preview__iframe', $contentPreview);

            $iframe.width(breakpoint);
            $iframe.height(breakpoint / (9/16));
        },

        removeClassModifiers = function($element, className) {
            $element.removeClass(function(i, classes) {
                var regex = new RegExp('(^|\\s)' + className + '--\\S+', 'g');
                return (classes.match(regex) || []).join(' ');
            });
        },

        changePreviewDeviceChrome = function($contentPreview, breakpointSize, breakpointName) {
            var $previewContainer = $('.content-preview__preview-container', $contentPreview),
                wideBreakPoint = WORKAREA.config.storefrontBreakPoints.wide;

            removeClassModifiers($previewContainer, 'content-preview__preview-container');

            if (breakpointSize < wideBreakPoint) {
                $previewContainer.addClass('content-preview__preview-container--device');
            }

            $previewContainer.addClass('content-preview__preview-container--' + breakpointName);
        },

        activatePreviwButton = function($previewButton) {
            var $breakpointButtons = $('.content-preview__breakpoint-button');

            $breakpointButtons.removeClass('content-preview__breakpoint-button--active');
            $previewButton.addClass('content-preview__breakpoint-button--active');
        },

        changePreviewSize = function(event) {
            var $previewButton = $(event.currentTarget),
                breakpointName = $previewButton.data('contentPreview'),
                $contentPreview = $previewButton.closest('.content-preview'),
                breakpointSize = WORKAREA.config.storefrontBreakPoints[breakpointName];

            event.preventDefault();

            resizeIframe($contentPreview, breakpointSize);
            changePreviewDeviceChrome($contentPreview, breakpointSize, breakpointName);
            activatePreviwButton($previewButton);
        },

        handleOpenPreview = function(event) {
            var previewUrl = event.currentTarget.href;

            event.preventDefault();

            $.get(previewUrl).done(WORKAREA.takeover.open);
        },

        initActions = function(index, previewControl) {
            var $previewControl = $(previewControl),
                action = $previewControl.data('contentPreview');

            if (action === 'open') {
                $previewControl.on('click', handleOpenPreview);
            } else {
                $previewControl.on('click', changePreviewSize);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.contentPreview
         */
        init = function ($scope) {
            $('[data-content-preview]', $scope)
            .each(initActions);
        };

    return {
        init: init
    };
}()));
