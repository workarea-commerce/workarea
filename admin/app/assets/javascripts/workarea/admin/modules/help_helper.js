WORKAREA.registerModule('helpHelper', (function () {
    'use strict';

    var template = JST['workarea/admin/templates/help_helper'],
        textTemplate = JST['workarea/admin/templates/help_helper_text'],

        tooltipDelay = 28000, // real shakey

        active = false,
        logged = [],

        // https://www.base64encode.org
        messages = [
            'SnVzdCBzbyB3ZSdyZSBjbGVhciwgdGhlIHNvZnR3YXJlIGlzIGNhbGxlZCBXb3Jr' +
            'YXJlYSBub3cgYnV0IEknbSBzdGlsbCBMaW5jeS4gR290IGl0PyBHb29kIQ==',
            'SGV5LCBkaWQgeW91IGtub3cgdGhlIGFkbWluIHN1cHBvcnRzIHRyYW5zbGF0aW9u' +
            'cyBub3c/ISBTaSwgZGUgbmFkYSE=',
            'U2hvcGlmeSBoYXMgYmVlbiB0cnlpbmcgdG8gcG9hY2ggbWUgdmlhIExpbmtlZElu' +
            '4oCmIElHTk9SRSE=',
            'SSd2ZSBoZWFyZCB0aGF0IG1vc3QgcGVvcGxlIHJlc3BvbnNpYmxlIGZvciA0MDQg' +
            'cGFnZXMgY2FuIG5vdCBiZSBmb3VuZA==',
            'VW50aWwgbmV4dCB0aW1lLCAjWW91J3JlX0l0',
            'TGluY3kgU2F5OiBJZiBhIHRyZWUgZmFsbHMgaW4gdGhlIHdvb2RzIGJ1dCB0aGVy' +
            'ZSdzIG5vYm9keSBhcm91bmQgdG8gaGVhciBpdCwgdGhlbiB3aG8gZ2l2ZXMgYSAq' +
            'KioqIGFib3V0IHRoaXMgdHJlZT8=',
            'TGluY3kgU2F5OiBFY29tbWVyY2UgaXMgbm90IGEgbXlzdGVyeSB0byBiZSBzb2x2' +
            'ZWQgd2hlbiB5b3UncmUgdXNpbmcgV29ya2FyZWEh',
            'TGluY3kgU2F5OiBNYW4gd2hvIHNlbGxzIGZsYXNobGlnaHRzIGhhcyBhIGJyaWdo' +
            'dCBmdXR1cmUuIE1hbiB3aG8gc2VsbHMgY2hlYXAgc3VuZ2xhc3NlcyBtYWtlcyBz' +
            'aGFkeSBkZWFscy4=',
            'TGluY3kgU2F5OiBNYW4gd2hvIGxldHMgZ2lyYWZmZSBydW4gaGlzIGJ1c2luZXNz' +
            'IG1heSBiZSByaXNraW5nIGhpcyBuZWNr'
        ],

        clickMessages = [
            'SGV5ISBEb24ndCBwb2tlIG1lIQ==',
            'SSdtIHNlcmlvdXMhIFRoYXQncyByZWFsbHkgYW5ub3lpbmch',
            'VGhhdCdzIGl0ISBJJ20gb3V0IG9mIGhlcmUh'
        ],

        getConfig = function (intro, message) {
            return _.assign({}, WORKAREA.config.tooltipster, {
                animation: 'fade',
                content: textTemplate({
                    intro: window.atob(intro),
                    message: window.atob(message)
                }),
                contentAsHTML: true,
                interactive: true,
                trigger: 'custom'
            });
        },

        init = function () {
            var $helpHelper = $('.help-helper__body', template()),
                $helpBurger = $('.help-helper__burger', template()),
                $trueMenu = $('.help-helper__true-menu', template()),
                $miniHelper = $('.help-helper__mini-helper', template()),
                $helpTakeover = $('.help-helper__takeover', template()),
                intro = 'SSdtIExpbmN5ITxicj5JJ20gaGVyZSB0byBoZWxwIQ==',
                message = messages[_.random(0, messages.length - 1)],
                clickCount = 0,
                config = getConfig(intro, message);

            active = true;

            WORKAREA.initModules($trueMenu);

            $('body').append(
                $helpHelper, $helpBurger, $trueMenu, $miniHelper, $helpTakeover
             );

            $helpHelper.tooltipster(config);

            _.delay(function () {
                $helpHelper
                .tooltipster('open')
                .on('mousedown', function () {
                    $helpHelper.tooltipster('content', textTemplate({
                        intro: window.atob(clickMessages[clickCount]),
                        message: null
                    }));

                    clickCount += 1;

                    if (clickCount === clickMessages.length) {
                        _.delay(function () {
                            $helpHelper.tooltipster('close', function () {
                                $helpHelper.fadeOut();
                                $trueMenu.fadeOut(function () {
                                    $(this).remove();
                                });
                            });
                        }, 2000);
                    }
                });
            }, tooltipDelay);
        },

        sequence = function () {
            return [38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
        },

        reset = function () {
            keys = sequence();
            logged = [];
        },

        keys = sequence(),

        readKeystroke = function (event) {
            if (active) { return; }

            if (keys.shift() === event.which) {
                logged.push(event.which);
            } else {
                reset();
            }

            if (_.isEqual(logged, sequence())) {
                reset();
                init();
            }
        };

    $(document).on('keydown', readKeystroke);
}()));
