(function () {
    'use strict';

    describe('WORKAREA.checkoutPrimaryPayments', function () {
        describe('activatePaymentMethod', function () {
            it('selects only one payment method', function () {
                var $newCard,
                    $savedCard,
                    $scope = fixture.load('checkout_primary_payments.html'),
                    selected = 'checkout-payment__primary-method--selected';

                WORKAREA.checkoutPrimaryPayments.init($scope);

                $newCard = $('#new_card');
                $savedCard = $('#saved_card');

                expect($newCard.length).to.equal(1);
                expect($savedCard.length).to.equal(1);

                expect($newCard.hasClass(selected)).to.equal(true);
                expect($savedCard.hasClass(selected)).to.equal(false);

                $savedCard.trigger('click');
                $newCard = $('#new_card');
                $savedCard = $('#saved_card');

                expect($newCard.hasClass(selected)).to.equal(false);
                expect($savedCard.hasClass(selected)).to.equal(true);
            });
        });
    });
}());
