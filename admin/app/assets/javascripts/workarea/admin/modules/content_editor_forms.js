/**
 * Handles the content block preview iframe functionality which is updated each
 * time the related form is updated.
 *
 * @namespace WORKAREA.contentEditorForms
 */
WORKAREA.registerModule('contentEditorForms', (function () {
    'use strict';

    var updatePreview = function (previewId, response) {
            $('.content-block__iframe', previewId)
            .attr('src', WORKAREA.routes.storefront.draftContentBlockPath({
                id: response.id
            }));
        },

        buildParams = function (form, preview) {
            var params = _.union(form, _.map(preview, function (value, name) {
                return { name: name, value: value };
            }));

            return _.reduce(params, function (result, value) {
                if (value.name !== '_method') { result.push(value); }
                return result;
            }, []);
        },

        preventPreviewReload = function (element) {
            var bannedSelectors = [
                    '[data-publish-with-release-menu]',
                    '[name="block[custom_name]"]'
                ];

            return $(element).is(bannedSelectors.join(','));
        },

        postFormData = _.debounce(function (event) {
            var $form, previewData, formParams, formData;

            if (preventPreviewReload(event.target)) { return; }

            $form = $(event.target).closest('form'),
            previewData = $form.data('contentEditorForm'),
            formParams = $form.serializeArray(),
            formData = buildParams(formParams, previewData.params);

            $.post(WORKAREA.routes.admin.contentBlockDraftsPath(), formData)
            .done(_.partial(updatePreview, previewData.previewId));
        }, WORKAREA.config.contentEditorForms.previewDebounceValue),

        /**
         * @method
         * @name init
         * @memberof WORKAREA.contentEditorForms
         */
        init = function ($scope) {
            $('[data-content-editor-form]', $scope)
            .on('input change wysiwygs:input', postFormData);
        };

    return {
        init: init,
        buildParams: buildParams
    };
}()));
