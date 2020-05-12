/**
 * @namespace WORKAREA.privacyPopup
 */
WORKAREA.registerModule('privacyPopup', (function () {
    'use strict';

    var markUserHasSeenPopup = function () {
            WORKAREA.cookie.create('cookies_accepted', 'true', 999);
        },

        userHasSeenPopup = function () {
            return Boolean(WORKAREA.cookie.read('cookies_accepted'));
        },

        isOnPrivacyPolicyPage = function () {
            return window.location.pathname ===
                WORKAREA.routes.storefront.pagePath({ id: 'privacy-policy' });
        },

        showPopup = function () {
            WORKAREA.dialog.create(
                $('[data-privacy-popup]').remove(),
                {
                    uiDialogOptions: {
                        modal: true,
                        closeOnEscape: false,
                        classes: {
                            'ui-dialog': 'privacy-popup'
                        },
                        open: function (event, ui) {
                            $('.ui-dialog-titlebar-close', ui.dialog | ui).hide();
                        },
                        buttons: [{
                            text: I18n.t('workarea.storefront.users.agree'),
                            click: function () {
                                markUserHasSeenPopup();
                                $(this).dialog('close');
                            }
                        }]
                    }
                }
            );
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.privacy
         */
        init = _.once(function () {
            if (!$('[data-privacy-popup]').length) { return; }
            if (isOnPrivacyPolicyPage()) { return; }
            if (!userHasSeenPopup()) { showPopup(); }
        });

    return {
        init: init
    };
}()));
