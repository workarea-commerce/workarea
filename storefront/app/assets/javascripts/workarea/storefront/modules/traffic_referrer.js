/**
 * @namespace WORKAREA.trafficReferrer
 */
WORKAREA.registerModule('trafficReferrer', (function () {
    'use strict';

    var referrer = document.referrer,

        setReferrer = function (url) {
            referrer = url;
        },

        isSameHost = function(referrer) {
            var currentUrl = WORKAREA.url.parse(document.URL),
                referrerUrl = WORKAREA.url.parse(referrer);

            return currentUrl.host === referrerUrl.host;
        },

        setCookie = function() {
            var currentCookie = WORKAREA.cookie.read('workarea_referrer');

            if (!referrer || currentCookie || isSameHost(referrer)) { return; }

            WORKAREA.cookie.create('workarea_referrer', referrer, 7);
        };

    return {
        setReferrer: setReferrer,
        setCookie: setCookie,
        init: _.once(setCookie)
    };
}()));
