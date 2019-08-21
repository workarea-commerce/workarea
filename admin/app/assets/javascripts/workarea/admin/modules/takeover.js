/**
 * Creates a UI that takes over the current page, using the `.header` component
 * for it's controls.
 *
 * @namespace WORKAREA.takeover
 */
WORKAREA.registerModule('takeover', (function () {
    'use strict';

    var takeover = JST['workarea/admin/templates/takeover'],

        handleEscKey = _.once(function () {
            $(window).on('keyup.takeover', function (event) {
                if (event.keyCode !== 27) { return; } // only care about escape
                close();
            });
        }),

        /**
         * Closes and destroys a takeover.
         * @param  {Boolean} force bypasses transitionevent (optional)
         */
        close = function (force) {
            var $takeover = $('#takeover');

            $('#header').removeClass('header--takeover');
            $takeover.addClass('takeover--removing');

            if (!feature.cssTransform || force) {
                $takeover.remove();
            } else {
                $takeover.on(WORKAREA.transitionEvents.detect(), function(event) {
                    $(event.currentTarget).remove();
                });
            }
        },

        create = function (content, options) {
            var $takeover = $(takeover({
                content: content,
                takeoverClass: options.takeoverClass || ''
            }));

            $takeover.data('takeoverOptions', options);

            WORKAREA.initModules($takeover);

            $('body').append($takeover);

            return $takeover;
        },

        addClass = function () {
            $('#header').addClass('header--takeover');
        },

        bindCloseButton = function () {
            var $closeButton = $('#takeover_close_button');

            if ($closeButton.data('takeoverCloseButton')) { return; }

            $closeButton.on('click', close);
            $closeButton.data('takeoverCloseButton', true);

            handleEscKey();
        },

        allowOneTakeover = function () {
            if ( ! _.isEmpty($('#takeover'))) {
                throw new Error(
                    I18n.t('workarea.admin.js.takeover.allow_one_takeover')
                );
            }
        },

        /**
         * Updates the takeover content
         * @param  {string} content content a string of HTML to show in the takeover
         * @return {jQuery} an instance of the takeover
         */
        update = function (content) {
            var $content = $(content);

            WORKAREA.initModules($content);

            $('#takeover .takeover__content')
            .empty()
            .append($content);

            return $('#takeover');
        },

        setup = _.flow(allowOneTakeover, bindCloseButton, addClass),

        /**
         * Opens a takeover UI.
         * @param {string} content a string of HTML to show in the takeover
         * @return {jQuery} an instance of the takeover
         */
        open = function(content, options) {
            options = options || {};

            setup();
            return create(content, options);
        },

        /**
         * Returns the current takeover UI instance
         * @returns {jQuery} the takeover
         */
        current = function () {
            return $('#takeover');
        },

        /**
         * Reloads the current takeover UI
         */
        reload = function () {
            var $takeover = current();
            var options;

            if (_.isEmpty($takeover)) {
                throw new Error(
                    'WORKAREA.takeover.reload: could not find an open ' +
                    'takeover to reload.'
                );
            }

            options = $takeover.data('takeoverOptions');

            if (_.isEmpty(options.reloadUrl)) {
                throw new Error(
                    'WORKAREA.takeover.reload: could not reload the takeover ' +
                    'due to a missing `reloadUrl` option that should have ' +
                    'been passed to the `WORKAREA.takeover.open` method.'
                );
            }

            $.get(options.reloadUrl).done(function (response) {
                close(true);
                open(response, options);
            });
        };

    $(document).on('turbolinks:before-cache', close);

    return {
        open: open,
        close: close,
        update: update,
        reload: reload,
        current: current
    };
}()));
