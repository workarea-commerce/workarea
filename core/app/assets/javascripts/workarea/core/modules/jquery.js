/**
 * @namespace WORKAREA.jQuery
 */
WORKAREA.registerModule('jQuery', (function () {
    'use strict';

    var createXhrWithoutXhrHeader = function () {
            // Get new xhr object using default factory
            var xhr = jQuery.ajaxSettings.xhr();

            // Copy the browser's native setRequestHeader method
            var setRequestHeader = xhr.setRequestHeader;

            // Replace with a wrapper
            xhr.setRequestHeader = function(name, value) {
                // Ignore the X-Requested-With header
                if (name === 'X-Requested-With' || name === 'If-None-Match') {
                    return;
                }

                // Otherwise call the native setRequestHeader method
                // Note: setRequestHeader requires its 'this' to be the xhr
                // object, which is what 'this' is here when executed.
                setRequestHeader.call(this, name, value);
            };

            // pass it on to jQuery
            return xhr;
        };

    return {
        createXhrWithoutXhrHeader: createXhrWithoutXhrHeader
    };
}()));
