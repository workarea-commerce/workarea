/**
 * @namespace WORKAREA.newNavigationTaxons
 */
WORKAREA.registerModule('newNavigationTaxons', (function () {
    'use strict';

    var getConfig = function ($select) {
            var $option = $('option:selected', $select);

            return _.merge(WORKAREA.config.remoteSelects, {
                ajax: {
                    url: $option.data('newNavigationTaxonEndpoint')
                },
                placeholder: '',
                allowClear: true
              });
        },

        destroyRemoteSelect = function ($select) {
            $select.val(null).trigger('change').select2('destroy');
        },

        createRemoteSelect = function (event) {
            var $typeSelect = $(event.currentTarget),
                $idSelect = $('[name=navigable_id]', event.delegateTarget),
                $section = $typeSelect.closest('[data-new-navigation-taxon]'),
                settings = getConfig($typeSelect),
                selected = $section.data('newNavigationTaxon');

            if ($idSelect.is('.select2-hidden-accessible') && _.isUndefined(selected)) {
                destroyRemoteSelect($idSelect);
            }

            $idSelect.select2(settings).val(selected);
        },

        changeRemoteSelect = function (index, element) {
            var $navigationLink = $(element);

            $navigationLink
            .on('change', '[name=navigable_type]', createRemoteSelect)
                .find('[name=navigable_type]')
                .trigger('change');
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.newNavigationTaxons
         */
        init = function ($scope) {
            $('[data-new-navigation-taxon]', $scope)
            .each(changeRemoteSelect);
        };

    return {
        init: init
    };
}()));
