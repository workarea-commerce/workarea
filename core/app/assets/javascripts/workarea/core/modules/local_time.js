/**
 * @namespace WORKAREA.localTime
 *
 * This module just ensures that LocalTime runs in case new content is inserted
 * for this scope.
 *
 */
WORKAREA.registerModule('localTime', (function () {
    'use strict';

    return {
        init: function () {
            LocalTime.run();
        }
    };
}()));
