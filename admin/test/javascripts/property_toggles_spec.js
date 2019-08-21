(function () {
    'use strict';

    describe('WORKAREA.propertyToggles', function () {
        describe('init', function () {
            /*jshint multistr: true */
            it('disables blank fields before submisson ', function () {

                var $fixture = fixture.load(
                    'property_toggle.html', false
                );

                WORKAREA.propertyToggles.init($($fixture));

                $('.property-toggle__checkbox :input', $fixture)
                .prop('checked', true);
                $('#select1').val('');
                $('#select2').val('');

                $('.property-toggle-form', $fixture)
                    .on('submit', function(e) { e.preventDefault(); })
                    .trigger('submit');

                expect($('#select1', $fixture).prop('disabled')).to.equal(
                    true
                );
                expect($('#select2', $fixture).prop('disabled')).to.equal(
                    false
                );
            });
        });
    });
}());
