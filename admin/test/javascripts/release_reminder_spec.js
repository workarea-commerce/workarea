(function () {
    'use strict';

    describe('WORKAREA.releaseReminder', function () {
        describe('closeTooltip', function () {
            it('closes tooltip after choice is made', function () {
                this.fixtures = fixture.load('release_reminder.html');
                WORKAREA.releaseReminder.init($(this.fixtures));

                expect($('.tooltipster-base').length).to.equal(1);

                $('[data-release-reminder-no]').trigger('click');

                expect($('.tooltipster-base').length).to.equal(0);
            });
        });
    });
}());
