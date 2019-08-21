/**
 * @namespace WORKAREA.cloneableRows
 */
WORKAREA.registerModule('cloneableRows', (function () {
    'use strict';

    var createClonedID = function (index, id) {
            return id + '_cloned_' + index;
        },

        getDefaultValue = function () {
            return this.defaultValue;
        },

        cloneRow = function ($row) {
            var $clonedRow = $row.clone();

            $clonedRow
            .insertAfter($row)
                .find('[name],[for]')
                .val(getDefaultValue)
                .prop('id', createClonedID)  // needed to pass integration tests
                .prop('for', createClonedID);

            $row
                .find('.value__note')
                .remove();

            WORKAREA.initModules($clonedRow);
        },

        removeListeners = function ($row) {
            return $row.off('input.cloneableRows click.cloneableRows');
        },

        getTarget = function (event) {
            return $(event.delegateTarget);
        },

        handleInput = _.flowRight(cloneRow, removeListeners, getTarget),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.cloneableRows
         */
        init = function ($scope) {
            $scope
                .find('[data-cloneable-row]')
                    .addBack('[data-cloneable-row]')
                    .on('input.cloneableRows', '[name]', handleInput)
                    .on('click.cloneableRows', 'input[type=file]', handleInput);
        };

    return {
        init: init
    };
}()));
