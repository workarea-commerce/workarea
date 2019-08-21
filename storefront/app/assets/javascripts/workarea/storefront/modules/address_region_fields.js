// TODO: v4 refactor, and may god have mercy on our souls.
/**
 * @namespace WORKAREA.addressRegionFields
 */
WORKAREA.registerModule('addressRegionFields', (function () {
    'use strict';

    var updateSelectUI = function ($regionField, $regionOptGroup) {
            var $select = $('select', $regionField),
                optGroupHTML = $regionOptGroup.prop('outerHTML');

            $select.find('optgroup').remove();
            $select.append(optGroupHTML);
        },

        resetSelectUI = function (countryField) {
            var $countryField = $(countryField),
                $addressFields = $countryField.closest('.address-fields'),
                $regionField = $('[data-address-region-fields="region"]', $addressFields),
                initialSelectState = $regionField.data('regionSelect');

            $('select', $regionField).empty().append(initialSelectState);
        },

        swapRegionField = function(index, countryField) {
            var $countryField = $(countryField),
                countryName = $('option:selected', $countryField).text(),
                $addressFields = $countryField.closest('.address-fields'),
                $regionField = $('[data-address-region-fields="region"]', $addressFields),
                regionCode = $('option:selected', $regionField).val(),
                $regionSelect = $('select', $regionField),
                $regionTextBox = $('input', $regionField),
                $regionOptGroup = $('optgroup[label="' + countryName + '"]', $regionSelect),
                $regionOptions = $('option', $regionOptGroup),
                $currentOption = $regionOptions.filter(function(_index, option) {
                    return $(option).val() === regionCode;
                }),
                $regionRequirementIndicator = $('.property__requirement', $regionField);

            $regionOptions.prop('selected', false);
            $currentOption.prop('selected', true);

            if (_.isEmpty($regionOptions)) {
                $regionSelect.addClass('hidden');
                $regionTextBox.removeClass('hidden');
                $regionRequirementIndicator.addClass('hidden');
            } else {
                updateSelectUI($regionField, $regionOptGroup);
                $regionTextBox.addClass('hidden');
                $regionSelect.removeClass('hidden');
                $regionRequirementIndicator.removeClass('hidden');
            }
        },

        setRegionField = function(event) {
            var $selectBox = $(event.currentTarget),
                $textBox = $('input', event.delegateTarget);

            $textBox.val($selectBox.val());
        },

        saveInitialSelectState = function (index, regionField) {
            var $select = $('select', regionField);
            $(regionField).data('regionSelect', $select.prop('innerHTML'));
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.addressRegionFields
         */
        init = function ($scope) {
            var $countryField = $('[data-address-region-fields="country"]', $scope),
                $regionField = $('[data-address-region-fields="region"]', $scope);

            $regionField.each(saveInitialSelectState);

            $countryField
            .on('change', 'select', function(event) {
                resetSelectUI(event.delegateTarget);
                swapRegionField(null, event.delegateTarget);
            })
            .each(swapRegionField);

            $regionField.on('change', 'select', setRegionField);
        };

    return {
        init: init
    };
}()));
