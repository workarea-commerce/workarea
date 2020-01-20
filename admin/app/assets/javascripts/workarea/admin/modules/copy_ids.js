/**
 * @namespace WORKAREA.copyIds
 */
WORKAREA.registerModule('copyIds', (function () {
    'use strict';

    var randomizeID = function (event) {
            var form = event.delegateTarget,
                $target = $('[name$="[id]"]', form),
                hash = Math.random().toString(32).slice(2).toUpperCase();

            $target.val(hash);
        },

        copyOriginalID = function (event) {
            var form = event.delegateTarget,
                id = $('[name=source_id]', form).val(),
                $target = $('[name$="[id]"]', form);

            $target.val(id + '-copy');
        },

        setId = function(event) {
            var form = event.delegateTarget,
                $target = $('[name=original_id]', form),
                $containers = $('.property.hidden', form);

            $target.val(event.target.value);
            $containers.removeClass('hidden');
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.copyIds
         */
        init = function ($scope) {
            $('[data-copy-id]', $scope)
            .on('change', 'select[name=source_id]', setId)
            .on('click', 'button[value=copy_original]', copyOriginalID)
            .on('click', 'button[value=randomize]', randomizeID);
        };

    return {
        init: init
    };
}()));
