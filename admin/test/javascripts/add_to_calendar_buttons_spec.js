(function () {
    'use strict';
    describe('WORKAREA.addToCalendarButtons', function () {
        describe('init', function () {
            after(function () {
                $('.tooltipster-base').remove();
            });

            it('should toggle content on click', function () {
                this.fixture = fixture.load('add_to_calendar_button.html');

                this.$button = $('[data-add-to-calendar-button]');
                this.$toggle = $('[data-add-to-calendar-button-toggle]');

                WORKAREA.addToCalendarButtons.init($(this.fixture));

                this.$button.tooltipster('show');

                expect($('.tooltipster-content').text()).to.include('Foo');

                this.$toggle.trigger('click');

                expect($('.tooltipster-content').text()).to.include('Bar');
            });
        });
    });
}());
