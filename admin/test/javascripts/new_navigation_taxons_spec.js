(function () {
    'use strict';

    describe('WORKAREA.newNavigationTaxons', function () {
        describe('init', function () {
            it('initializes select2 on navigable id select', function () {
                var markup = 'new_navigation_taxon.html',
                    $fixture = $(fixture.load(markup, true)),

                    $select = $('[name=navigable_id]', $fixture);

                expect($select.is('.select2-hidden-accessible')).to.not.be.ok;

                WORKAREA.newNavigationTaxons.init($fixture);

                expect($select.is('.select2-hidden-accessible')).to.be.ok;
            });
        });
    });
}());
