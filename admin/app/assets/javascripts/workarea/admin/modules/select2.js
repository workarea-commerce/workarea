/**
 * @namespace WORKAREA.select2
 */
WORKAREA.registerModule('select2', (function () {
    'use strict';

    /**
     * @method
     * @name init
     * @memberof WORKAREA.select2
     */
    var init = function ($scope) {
        $('[data-select-two]', $scope).each(function(i, element) {
            var $select = $(element),
                options = $select.data('select-two');

            if (options.dropdownParentSelector) {
                options.dropdownParent = $(options.dropdownParentSelector);
                delete options.dropdownParentSelector;
            }

            $select.select2(options);
        });

    };

    return {
        init: init
    };
}()));
