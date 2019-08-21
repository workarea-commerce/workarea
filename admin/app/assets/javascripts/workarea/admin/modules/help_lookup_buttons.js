/**
 *
 * TODO remove in v4, no longer used
 *
 * Sets up the link for looking up help for the current page
 *
 * @namespace WORKAREA.helpLookupButtons
 */
WORKAREA.registerModule('helpLookupButtons', (function () {
    'use strict';

    var fetchHelp = function (url) {
            $.get(url)
            .done(function(response) {
                WORKAREA.takeover.open(response, { 'takeoverClass': 'takeover--from-top' });
            })
            .fail(_.partial(WORKAREA.url.redirectTo, url));
        },

        getHelpUrl = function (keywords) {
            return WORKAREA.routes.admin.helpIndexPath({
                like_text: keywords,
                for_url: window.location.pathname
            });
        },

        sanitizeText = function (index, element) {
            var text = $(element).text();

            text = text.replace(/workarea|admin/ig, '');
            text = text.replace(/\s{2,}/g, ' ');

            return _.trim(text);
        },

        getKeywords = function ($scope) {
            var config = WORKAREA.config.helpLookupButtons;
            return $(config.keywordElements.join(','), $scope)
                .map(sanitizeText)
                .get()
                .join(' ');
        },

        stopEvent = function ($scope, event) {
            event.preventDefault();
            return $scope;
        },

        openHelp = _.flow(stopEvent, getKeywords, getHelpUrl, fetchHelp),

       /**
        * @method
        * @name init
        * @memberof WORKAREA.helpLookupButtons
        */
        init = function ($scope) {
            $('[data-help-lookup-button]', $scope)
            .on('click', _.partial(openHelp, $scope));
        };

    return {
        init: init,
        sanitizeText: sanitizeText,
        getKeywords: getKeywords
    };
}()));
