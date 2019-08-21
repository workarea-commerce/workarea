(function () {
    'use strict';

    describe('WORKAREA.addressRegionFields', function () {
        describe('init', function () {
            it('sets up field swapping on country field change', function () {
                var $countrySelect, $regionText, $regionSelect, $selectedRegion;

                this.fixtures = fixture.load('address_region_fields.html', false);

                WORKAREA.addressRegionFields.init($(this.fixtures));

                $countrySelect = $('[data-address-region-fields="country"] select');
                $regionText = $('[data-address-region-fields="region"] input');
                $regionSelect = $('[data-address-region-fields="region"] select');
                $selectedRegion = $('option:selected', $regionSelect);

                expect($selectedRegion.text()).to.equal('Pennsylvania');

                expect($regionText.is(':hidden')).to.equal(true);
                expect($regionSelect.is(':hidden')).to.equal(false);

                $countrySelect.val('MX').trigger('change');
                expect($regionText.is(':hidden')).to.equal(false);
                expect($regionSelect.is(':hidden')).to.equal(true);

                $countrySelect.val('US').trigger('change');
                expect($regionText.is(':hidden')).to.equal(true);
                expect($regionSelect.is(':hidden')).to.equal(false);

                expect(_.isEmpty($('optgroup[label="United States"]'))).to.equal(false);
                expect(_.isEmpty($('optgroup[label="Canada"]'))).to.equal(true);

                $countrySelect.val('CA').trigger('change');
                expect(_.isEmpty($('optgroup[label="United States"]'))).to.equal(true);
                expect(_.isEmpty($('optgroup[label="Canada"]'))).to.equal(false);

                // refresh selected region
                $regionSelect = $('[data-address-region-fields="region"] select');
                $selectedRegion = $('option:selected', $regionSelect);

                expect(_.isEmpty($selectedRegion.val())).to.equal(true);
            });
        });
    });
}());
