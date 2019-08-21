(function () {
    'use strict';

    describe('WORKAREA.contentPresetForm', function () {
        describe('init', function () {
            it('dismisses tooltip upon submission of the remote form', function () {
                var $scope;

                fixture.set('<div class="tooltipster-base"><form id="content_presets_form"></form></div>');
                $scope = $(this.fixtures);
                WORKAREA.contentPresetForm.init($scope);
                $('#content_presets_form', $scope).trigger('ajax:success');

                expect($('.tooltipster-base', $scope).length).to.equal(0);
            });
        });
    });
}());
