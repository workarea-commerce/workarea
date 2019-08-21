/**
 * @namespace WORKAREA.authenticityToken
 */
WORKAREA.registerModule('authenticityToken', (function () {
    'use strict';

    var authenticityToken = JST['workarea/storefront/templates/authenticity_token'],
        appendAuthenticityToken = function(index, form) {
            WORKAREA.currentUser.gettingUserData.done(function(user) {
                var $form = $(form),
                    $existingInput = $('input[name="'+user.csrf_param+'"]', $form);

                if (_.isEmpty($existingInput)) {
                    $form.append(authenticityToken(user));
                } else {
                    $existingInput.val(user.csrf_token);
                }
            });
        },
        init = function($scope) {
            $('form', $scope).each(appendAuthenticityToken);
        };

    return {
        init: init
    };
}()));
