/**
 * @namespace WORKAREA.unsavedChanges
 */
WORKAREA.registerModule('unsavedChanges', (function () {
    'use strict';

    var unsavedChanges = false,

        reset = function() {
            unsavedChanges = false;
        },

        set = function () {
            unsavedChanges = true;
        },

        testUnsavedChanges = function(event) {
            if ($(event.target).is('[data-unsaved-changes-ignore]')) { return; }
            set();
        },

        promptBeforePageLoad = function(event) {
            var message = I18n.t('workarea.admin.form.unsaved_changed_message');

            if (unsavedChanges && !window.confirm(message)) {
                event.preventDefault();
            }
        },

        promptBeforeUnload = function(event) {
            var message = I18n.t('workarea.admin.form.unsaved_changed_message');

            if (! unsavedChanges) { return; }

            event.preventDefault();
            event.returnValue = message;
            return message;
        };

    // Running this in tests can cause browser dialogs for unsaved changes to
    // remain open and we don't care about that.
    if (!WORKAREA.environment.isTest) {
        $(document).on('change.unsavedChanges wysiwygs:input', '[data-unsaved-changes]', testUnsavedChanges);
        $(document).on('submit.unsavedChanges', '[data-unsaved-changes]', reset);

        document.addEventListener('turbolinks:load', reset);
        document.addEventListener('turbolinks:before-visit', promptBeforePageLoad);

        window.addEventListener('beforeunload', promptBeforeUnload);
    }

    return {
        set: set,
        reset: reset
    };
}()));
