/**
 * @namespace WORKAREA.checkoutAddressesForms
 */
WORKAREA.registerModule('checkoutAddressesForms', (function () {
    'use strict';

    var insertSameAsShippingTemplate = function (instance) {
            var $template = $(instance.sameAsShippingTemplate());

            instance.$billingAddressSection
                .find('.checkout-addresses__heading')
                .after($template);
        },

        toggleSameAsShipping = function (instance, checked) {
            instance.$billingAddressSection
                .find('[name=same_as_shipping]')
                .prop('checked', checked)
                .trigger('change');
        },

        showBillingAddressFields = function (instance) {
            instance.$billingAddressSection
                .find('.checkout-addresses__fields')
                .removeClass('hidden-if-js-enabled');
        },

        hideBillingAddressFields = function (instance) {
            instance.$billingAddressSection
                .find('.checkout-addresses__fields')
                .addClass('hidden-if-js-enabled');
        },

        serializeObject = function ($fields) {
            var result = {},
                fieldsArray = $fields.serializeArray();

            _.forEach(fieldsArray, function (field) {
                if (result[field.name] !== undefined) {
                    if (!result[field.name].push) {
                        result[field.name] = [result[field.name]];
                    }

                    result[field.name].push(field.value || '');
                } else {
                    result[field.name] = field.value || '';
                }
            });

            return result;
        },

        setSerializedAddresses = function (instance) {
            instance.shippingAddress = serializeObject(instance.$shippingAddressFields);
            instance.billingAddress = serializeObject(instance.$billingAddressFields);
        },

        getSelectedAddress = function (instance, $select) {
            var selectedAddressId = $select.val();

            return _.find(instance.savedAddresses, { '_id': selectedAddressId });
        },

        populateSelectedAddress = function (instance, $addressSection) {
            var region;

            _.forEach(instance.selectedAddress, function (value, key) {
                var $input = $('[name$="[' + key + ']"]', $addressSection);
                $input.val(value);
                if ( ! _.isEmpty(value)) { $input.trigger('change'); }
                if (key === 'region') { region = value; }
            });

            if ( ! _.isEmpty(region)) {
                $('[name$=address_region_select]', $addressSection).val(region);
            }
        },

        addressesMatch = function (instance) {
            return _.isEqual(_.values(instance.shippingAddress), _.values(instance.billingAddress));
        },

        listenForSavedAddressChange = function (instance, $addressSection) {
            $addressSection
                .find('select[name^="saved_addresses"]')
                .on('change', function () {
                    var $select = $(this);

                    instance.selectedAddress = getSelectedAddress(instance, $select);
                    populateSelectedAddress(instance, $addressSection);
                });
        },

        setupSavedAddresses = function (instance) {
            var insertAddresses = function ($addressSection, index) {
                    var $template = $(instance.savedAddressesTemplate({
                            counter: index,
                            addresses: instance.savedAddresses
                        }));

                    $addressSection
                        .find('.address-fields')
                        .prepend($template);
                };

            if (_.isEmpty(instance.savedAddresses)) { return; }

            instance.$shippingAddressSection
                .add(instance.$billingAddressSection)
                .each(function (index, section) {

                    insertAddresses($(section), index);
                    listenForSavedAddressChange(instance, $(section));
                });
        },

        setSameAsShippingToggleState = function (instance) {
            if (addressesMatch(instance)) {
                toggleSameAsShipping(instance, true);
            } else {
                toggleSameAsShipping(instance, false);
                showBillingAddressFields(instance);
            }
        },

        resetSavedAddressSelect = function ($section) {
            $section
                .find('select[name^="saved_addresses"]')
                .prop('selectedIndex', 0)
                .trigger('change');
        },

        forceShippingToBilling = function (instance) {
            instance.shippingAddress = serializeObject(instance.$shippingAddressFields);

            _.forEach(instance.shippingAddress, function (value, key) {
                key = key.replace('shipping_address', '');

                $('[name$="' + key + '"]', instance.$billingAddressSection).val(value);
            });
        },

        listenForSameAsShippingChange = function (instance) {
            instance.$billingAddressSection
                .find('[name=same_as_shipping]')
                .on('change', function () {
                    if ($(this).is(':checked')) {
                        hideBillingAddressFields(instance);
                        resetSavedAddressSelect(instance.$billingAddressSection);
                    } else {
                        showBillingAddressFields(instance);
                    }
                });
        },

        listenForShippingFormSubmit = function (instance) {
            var $sameAsShippingToggle = instance.$billingAddressSection.find('[name=same_as_shipping]');

            instance.$checkoutAddressesForm.on('submit', function (event) {
                if ($sameAsShippingToggle.is(':checked')) {
                    event.preventDefault();

                    if ($(this).valid()) {
                        forceShippingToBilling(instance);
                        this.submit();
                    }
                }
            });
        },

        consumeInstance = function (instance) {
            setupSavedAddresses(instance);
            setSerializedAddresses(instance);

            if ($('.checkout-addresses__section--shipping').length) {
                insertSameAsShippingTemplate(instance);
            }

            listenForSameAsShippingChange(instance);
            setSameAsShippingToggleState(instance);

            listenForShippingFormSubmit(instance);
        },

        createInstance = function ($scope, $checkoutAddressesForm) {
            return {
                $scope: $scope,
                $checkoutAddressesForm: $checkoutAddressesForm,
                $shippingAddressSection: $('.checkout-addresses__section--shipping', $checkoutAddressesForm),
                $shippingAddressFields: $('[name*="shipping_address"]', $checkoutAddressesForm),
                $billingAddressSection: $('.checkout-addresses__section--billing', $checkoutAddressesForm),
                $billingAddressFields: $('[name*="billing_address"]', $checkoutAddressesForm),
                savedAddresses: $checkoutAddressesForm.data('checkoutAddressesForm').savedAddresses,
                shippingAddress: undefined,
                billingAddress: undefined,
                selectedAddress: undefined,
                sameAsShippingTemplate: JST['workarea/storefront/templates/same_as_shipping_button_property'],
                savedAddressesTemplate: JST['workarea/storefront/templates/saved_addresses_property']
            };
        },

        initInstance = _.flowRight(consumeInstance, createInstance),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.checkoutAddressesForms
         */
        init = function ($scope) {
            var $checkoutAddressesForm = $(
                    '[data-checkout-addresses-form]', $scope
                );

            if (_.isEmpty($checkoutAddressesForm)) { return; }

            initInstance($scope, $checkoutAddressesForm);
        };

    return {
        init: init
    };
}()));
