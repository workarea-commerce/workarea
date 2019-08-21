/**
 * @namespace WORKAREA.messages
 */
WORKAREA.registerModule('messages', (function () {
    'use strict';

    var createMessage = JST['workarea/storefront/templates/message'],

        getPageMessageContainer = function () {
            return $('.page-messages').first();
        },

        /**
         * Stores all flash messages that have been rendered in the DOM
         */
        renderedMessages = {},

        inRenderedMessagesList = function(text, type) {
            return _.includes(renderedMessages[type], text);
        },

        inServerRenderedMessages = function(text, type) {
            var messageSelector = '.page-messages .message--'+type,
                $query = $(messageSelector+':contains("'+text+'")');

            return !_.isEmpty($query);
        },

        /**
         * Test if a flash message has been rendered to the screen
         * already.
         *
         * @param {String} type - Message type (either "success" or "error")
         * @param {String} text - Pre-escaped text that was entered into
                                  the `renderedMessages` collection.
         * @return {Boolean} whether the flash message has already been
         *                   rendered.
         */
        didRenderMessage = function(text, type) {
            return inRenderedMessagesList(text, type) && inServerRenderedMessages(text, type);
        },

        /**
         * Add a message into the `renderedMessages` collection.
         *
         *
         * @param {String} type - Message type (either "success" or "error")
         * @param {String} text - Pre-escaped text that was entered into
                                  the `renderedMessages` collection.
         */
        logMessage = function(type, text) {
            renderedMessages[type] = renderedMessages[type] || [];
            renderedMessages[type].push(text);
        },

        /**
         * Inserts a message into the DOM. If the `$parent` argument is omitted
         * the message is shown as a flash message to the top of the window.
         *
         * @param  {String} messageText - the main text/html of the message
         * @param  {String} messageType - the type of message
         * @param  {jQuery} $parent - the target for injection (optional)
         */
        insertMessage = function (messageText, messageType, $parent) {
            var $message = $(createMessage({
                messageText: messageText,
                messageType: WORKAREA.string.titleize(messageType),
                messageModifier: messageType.toLowerCase()
            }));

            logMessage(messageType, messageText);

            if ( ! ($parent instanceof jQuery) || _.isEmpty($parent)) {
                getPageMessageContainer().prepend($message);
            } else {
                $parent.append($message);
            }

            WORKAREA.initModules($message);

            return $message;
        },

        insertPageMessages = function (event, xhr) {
            var messagesHeader = xhr.getResponseHeader('X-Flash-Messages'),
                messages = JSON.parse(messagesHeader);

            _.forEach(messages, function(text, type) {
                if (!didRenderMessage(text, type)) {
                    insertMessage(text, type);
                }
            });
        },

        removeMessage = function ($message) {
            $message.remove();
        },

        dismissMessage = function ($message) {
            $message.addClass('message--removing');

            if ( ! feature.cssTransition) {
                removeMessage($message);
            } else {
                $message.on(WORKAREA.transitionEvents.detect(), function(event) {
                    removeMessage($(event.currentTarget));
                });
            }
        },

        dismissMessageAfterDelay = function ($message) {
            _.delay(
                _.partial(dismissMessage, $message),
                WORKAREA.config.messages.delay
            );
        },

        dismissClosestMessage = function (event) {
            var $closestMessage = $(event.currentTarget).closest('.message');

            dismissMessage($closestMessage);
        },

        createDismissAction = JST[
            'workarea/storefront/templates/message_dismiss_action'
        ],

        insertDismissAction = function ($message) {
            var $dismissAction = $(createDismissAction());

            $dismissAction.on('click', dismissClosestMessage);
            $message.append($dismissAction);
        },

        isPageMessage = function ($message) {
            return $message.parent().is(getPageMessageContainer());
        },

        isNotError = function ($message) {
            return ! $message.is('.message--error');
        },

        shouldDismissMessage = function ($message) {
            return isNotError($message) && isPageMessage($message);
        },

        initMessage = function (index, message) {
            var $message = $(message),
                type = $message.hasClass('message--error') ? 'error' : 'success',
                text = _.trim($message.find('.message__text').text());

            logMessage(type, text);

            if ($message.data('messageShowDismiss') !== false) { // true if not specified
                insertDismissAction($message);
            }

            if (shouldDismissMessage($message)) {
                dismissMessageAfterDelay($message);
            }
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.messages
         */
        init = function ($scope) {
            $scope.find('.message').addBack('.message').each(initMessage);
        };

    $(document).on('ajaxComplete', insertPageMessages);

    return {
        init: init,
        insertMessage: insertMessage,
        insertPageMessages: insertPageMessages
    };
}()));
