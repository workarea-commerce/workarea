/**
 * @namespace WORKAREA.breakPoints
 */
WORKAREA.registerModule('breakPoints', (function () {
    'use strict';

    var breakPoints,
        currentMatches = [],
        supportsMatchMedia = window.feature.matchMedia,
        fullSupport = false,

        createBreakPoints = function () {
            if (supportsMatchMedia) {
                breakPoints = _.reduce(WORKAREA.config.storefrontBreakPoints.sizes, function (obj, widthValue, widthName) {
                    obj[widthName] = window.matchMedia('(min-width: ' + widthValue + 'px)');
                    return obj;
                }, {});
            }
        },

        queryCurrentMatches = function () {
            currentMatches = _.reduce(breakPoints, function (newArray, mediaQuery, sizeName) {
                if (mediaQuery.matches) {
                    newArray.push(sizeName);
                }
                return newArray;
            }, []);
        },

        getInitialMatches = function () {
            if (!supportsMatchMedia) {
                currentMatches = WORKAREA.config.storefrontBreakPoints.ie9Matches;
                return;
            }

            queryCurrentMatches();
            fullSupport = true;
        },

        /**
         * @method
         * @name currentlyLessThan
         * @memberof WORKAREA.breakPoints
         * @param {string} widthName - Name of the breakpoint, e.g. 'small' or 'medium'
         */
        currentlyLessThan = function (widthName) {
            if (_.includes(_.keys(breakPoints), widthName)) {
                return !_.includes(currentMatches, widthName);
            } else {
                return false;
            }
        };

    createBreakPoints();
    getInitialMatches();

    if (fullSupport) {
        $(window).on('resize', _.debounce(queryCurrentMatches, 250));
    }

    return {
        currentlyLessThan: currentlyLessThan,
        currentMatches: currentMatches,
        // Public method for testing only
        createBreakPoints: createBreakPoints
    };
}()));
