(function () {
    'use strict';

    describe('WORKAREA.messages', function () {
        describe('insertMessage', function () {
            it('adds a flash message if no $parent is provided', function () {
                fixture.set('<p class="page-messages"></p>');

                WORKAREA.messages.insertMessage('foo', 'bar');

                expect($('.page-messages').text()).to.include('foo');
            });

            it('adds a static message if $parent is provided', function () {
                fixture.set('<p id="my-message"></p>');

                WORKAREA.messages.insertMessage('baz', 'bat', $('#my-message'));

                expect($('#my-message').text()).to.include('baz');
            });
        });

        describe('insertPageMessages', function() {
            it('will not add the same message twice', function () {
                var event = {},
                    xhr = {
                        getResponseHeader: function() {
                            return JSON.stringify({ ball: 'fuzz' });
                        }
                    };
                fixture.set('<p class="page-messages"></p>');

                WORKAREA.messages.insertPageMessages(event, xhr);
                WORKAREA.messages.insertPageMessages(event, xhr);

                expect($('.page-messages .message').length).to.equal(1);
            });
        });

        describe('initMessage', function () {
            it('does not add a dismiss if told not to', function () {
                fixture.set('<div class="messages" data-message-show-dismiss="false"></div>');

                WORKAREA.messages.init($(this.fixtures));

                expect($('.message__dismiss-action').length).to.equal(0);
            });
        });
    });
}());
