/**
 * @namespace WORKAREA.productCopyIds
 */
WORKAREA.registerModule('productCopyIds', (function () {
    'use strict';

    var init = function () {
            throw new Error(
                'WORKAREA.productCopyIds.init: this module has been ' +
                'deprecated in favor of the general-use module ' +
                'WORKAREA.copyIds. Please update your application\'s admin ' +
                'JavaScript manifest: \n\n' +
                'replace: workarea/admin/modules/product_copy_ids\n' +
                'with: workarea/admin/modules/copy_ids'
            );
        };

    return {
        init: init
    };
}()));
