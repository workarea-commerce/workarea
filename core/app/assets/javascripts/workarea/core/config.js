(function () {
    'use strict';

    window.WORKAREA.config = window.WORKAREA.config || {};

    /**
     * @namespace WORKAREA.config
     * @property {object} date
     * @property {object} categorizedAutocompleteFields
     * @property {object} deletionForms
     * @property {array} imageFileExtensions
     * @property {object} formSubmittingControls
     */

    WORKAREA.config.date = {
        format: '%Y-%m-%d %I:%M %P %:z',
        formatDate: '%Y-%m-%d',
        hours: '%I',
        minutes: '%M',
        ampm: '%P'
    };

    WORKAREA.config.categorizedAutocompleteFields = {
        uiOptions: {
            minLength: 2
        }
    };

    WORKAREA.config.deletionForms = {
        message: 'Are you sure you want to delete this?'
    };

    WORKAREA.config.imageFileExtensions = ['jpg', 'jpeg', 'gif', 'png'];

    WORKAREA.config.formSubmittingControls = {
        changeDelay: 500,
        inputDelay: 1000
    };

    /**
     * I18n
     */

    I18n.fallbacks = true;

    var locale = $('meta[property="locale"]').attr('content');
    if (locale) {
        I18n.locale = locale;
    }

    /**
     * CSRF Token configuration for jQuery Ajax requests
     */

    $(document).ajaxSend(function(event, xhr) {
        var token = $('meta[name=csrf-token]').attr('content');
        xhr.setRequestHeader('X-CSRF-Token', token);
    });
})();
