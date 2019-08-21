/**
 * @namespace WORKAREA.assetPickerFields
 */
WORKAREA.registerModule('assetPickerFields', (function () {
    'use strict';

    var addAsset = function (assetPickerField, event, asset) {
            $('input', assetPickerField).val(asset.id).trigger('change');
            $('[data-asset-name]', assetPickerField).text(asset.name);
            $('[data-asset-url]', assetPickerField).val(asset.url).trigger('change');
            $(window).off('assetPickers:insert');
        },

        clearAsset = function (event) {
            var assetPickerField = event.delegateTarget;

            $('input', assetPickerField).val('').trigger('change');
            $('[data-asset-name]', assetPickerField).text(
                I18n.t('workarea.admin.content_blocks.asset.name_missing')
            );
        },

        openAssetPickerTakeover = function (event) {
            event.preventDefault();

            $.get(event.currentTarget.href).done(function (response) {
                WORKAREA.takeover.open(response, {
                    reloadUrl: event.currentTarget.href
                });
            });

            $(window).on(
                'assetPickers:insert', _.partial(addAsset, event.delegateTarget)
            );
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.assetPickerFields
         */
        init = function ($scope) {
            $('[data-asset-picker-field]', $scope)
            .on('click', '[data-asset-picker-field-open]', openAssetPickerTakeover)
            .on('click', '[data-asset-picker-field-clear]', clearAsset);
        };

    return {
        init: init
    };
}()));
