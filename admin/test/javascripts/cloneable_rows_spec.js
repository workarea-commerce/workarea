(function () {
    'use strict';

    describe('WORKAREA.cloneableRows', function () {
        describe('init', function () {
            var triggerClone = function ($scope) {
                    $('tr:first [name]', $scope)
                        .first()
                        .trigger('input.cloneableRows');
                },

                $fixture;

            beforeEach(function () {
                var markup = 'cloneable_row.html';

                $fixture = $(fixture.load(markup, true));

                WORKAREA.cloneableRows.init($fixture);
            });

            it('clones its row on field input', function () {
                expect($('tr', $fixture).length).to.equal(1);
                expect($('label', $fixture).attr('for')).to.equal('foo');
                triggerClone($fixture);
                expect($('tr', $fixture).length).to.equal(2);
                expect($('tr:nth-child(2) label', $fixture).attr('for')).not.to.equal('foo');
            });

            it('clones itself only once', function () {
                triggerClone($fixture);
                triggerClone($fixture);

                expect($('tr', $fixture).length).to.equal(2);
            });
        });
    });
}());
