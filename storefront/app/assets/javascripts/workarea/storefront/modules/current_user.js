// TODO v4 rewrite to not assign directly to currentUser. Use closure instead.
/**
 * @namespace WORKAREA.currentUser
 */
WORKAREA.registerModule('currentUser', (function () {
    'use strict';

    var refresh = function() {
        return $.getJSON(
            WORKAREA.routes.storefront.currentUserPath({ format: 'json' }),
            function (result) { _.assign(WORKAREA.currentUser, result); }
        );
    };

    /**
     * @method
     * @name gettingUserData
     * @memberof WORKAREA.currentUser
     */

    return {
        refresh: refresh,
        gettingUserData: $.getJSON(
            WORKAREA.routes.storefront.currentUserPath({ format: 'json' }),
            function (result) { _.assign(WORKAREA.currentUser, result); }
        )
    };
}()));
