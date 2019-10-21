/**
 * @namespace WORKAREA.tributeAreas
 */
 WORKAREA.registerModule('tributeAreas', (function () {
    'use strict';

    var hiddenInput = JST['workarea/core/templates/hidden_input'],

        getValidMentions = function ($form) {
            var $element = $form.find('[data-tribute-area]'),
                words = $element.val().split(/\s+/),
                storedMentions = $element.data('tributeMentions') || [],
                typedMentions = _.filter(words, function (word) {
                    return word.startsWith(
                        WORKAREA.config.tributeAreas.trigger
                    );
                });

            return _.filter(storedMentions, function (stored) {
                var value = stored.original.fillAttr;
                return _.some(typedMentions, _.method('includes', value));
            });
        },

        updateForm = function (event) {
            var $form = $(event.target);

            _.forEach(getValidMentions($form), function (mention) {
                $form.append(function () {
                    return hiddenInput({
                        name: 'subscribed_user_ids[]',
                        value: mention.original.id
                    });
                });
            });
        },

        requestData = function (element, text, resolve) {
            var baseUrl = $(element).data('tributeArea'),
                endpoint = WORKAREA.url.addToQuery(baseUrl, 'q=' + text);

            $.get(endpoint)
            .done(function (response) {
                resolve(response.mentions);
            })
            .fail(function () {
                resolve([]);
            });
        },

        storeMention = function (event) {
            var mentions = $(event.target).data('tributeMentions') || [];
            mentions.push(event.detail.item);
            $(event.target).data('tributeMentions', mentions);
        },

        setup = function (index, element) {
            var tribute = new Tribute({
                collection: [
                    {
                        trigger: WORKAREA.config.tributeAreas.trigger,
                        values: function (text, callback) {
                            requestData(element, text, function (mentions) {
                                return callback(mentions);
                            });
                        },
                        lookup: 'lookup',
                        fillAttr: 'fillAttr'
                    }
                ]
            });

            tribute.attach(element);

            $(element).on('tribute-replaced', storeMention);
            $(element).closest('form').on('submit', updateForm);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.tributeAreas
         */
        init = function (scope) {
            $('[data-tribute-area]', scope).each(setup);
        };

    return {
        init: init
    };
}()));
