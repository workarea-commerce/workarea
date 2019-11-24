/**
 * @namespace WORKAREA.selects
 */
WORKAREA.registerModule('selects', (function () {
    'use strict';

    /**
     * @method
     * @name init
     * @memberof WORKAREA.selects
     */
    var getConfig = function (select) {
            var config = _.assign({}, $(select).data('select'));

            if ( ! _.isUndefined(config.dropdownParent)) {
                config.dropdownParent = $(config.dropdownParent);
            }

            return config;
        },

        setup = function(index, select) {
            var config = getConfig(select),
                $select = $(select);

            if (config.allowClear) {
                $select.before(JST['workarea/core/templates/hidden_input']({
                    name: $select.attr('name'),
                    value: ''
               }));
            }

            $select.select2(config);
        },

        init = function ($scope) {
            $('[data-select]', $scope).each(setup);
        };

    return {
        init: init
    };
}()));
