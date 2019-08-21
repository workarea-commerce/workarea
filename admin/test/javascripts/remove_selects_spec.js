(function () {
    'use strict';

    describe('WORKAREA.remoteSelects', function () {
        describe('init', function () {
            it('adds a hidden input before the select', function () {
                var markup = 'remote_select.html',
                    $fixture = $(fixture.load(markup, true)),

                    $select = $('select', $fixture),
                    inputName = $select.attr('name');

                WORKAREA.remoteSelects.init($fixture);

                expect($select.prev().attr('type')).to.equal('hidden');
                expect($select.prev().attr('name')).to.equal(inputName);
            });

            it('configures the default settings of the instance', function () {
                var markup = 'remote_select.html',
                    $fixture = $(fixture.load(markup, true)),
                    $input;

                WORKAREA.remoteSelects.init($fixture);

                $input = $('.select2-search__field', $fixture);

                expect($input.attr('placeholder')).to.equal('Baz');
            });
        });
    });
}());
