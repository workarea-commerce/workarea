// TODO: v4 refactor
/**
 * @namespace WORKAREA.publishWithReleaseMenus
 */
WORKAREA.registerModule('publishWithReleaseMenus', (function () {
    'use strict';

    var newReleaseOptionTemplate = JST['workarea/admin/templates/new_release_option'],

        updateTitleAttribute = function (select) {
            var title = $('option:selected', select).text();
            $(select).attr('title', title);
        },

        switchRelease = function (select) {
            $.post(WORKAREA.routes.admin.releaseSessionPath(), {
                release_id: $(select).val()
            }).done(function () {
                $(select).tooltipster('close');

                if ($(select).data('publishWithReleaseMenu') !== 'async') {
                    window.location.reload();
                }
            });
        },

        removeNewReleaseOption = function (select) {
            $('[data-new-release-option]', select).remove();
        },

        updateSelect = function (select, newRelease) {
            $(select).append(function () {
                return $('<option>').val(newRelease._id).text(newRelease.name);
            }).val(newRelease._id);
        },

        addNewRelease = function (select, event) {
            var endpoint = event.currentTarget.action,
                data = $(event.currentTarget).serialize();

            event.preventDefault();

            $.post(
                endpoint,
                data,
                function (response) {
                    updateSelect(select, response.release);
                    removeNewReleaseOption(select);
                    switchRelease(select);
                }
            );
        },

        handleFormSubmit = function (select, event) {
            addNewRelease(select, event);
        },

        requestNewReleaseForm = function (instance, helper) {
            $.get(WORKAREA.routes.admin.newReleasePath())
            .done(function (response) {
                var $content = $(response),
                    $form = $('form', $content),
                    $input = $('[name="release[name]"]', $form),
                    select = helper.origin;

                WORKAREA.initModules($content);

                $form.on('submit', _.partial(handleFormSubmit, select));

                instance.content($content);

                $input.trigger('focus');
            });
        },

        testNewReleaseOption = function (event) {
            var $select = $(event.currentTarget),
                $selectedOption = $('option:selected', $select);

            if ($selectedOption.data('newReleaseOption')) {
                $(event.currentTarget).tooltipster('open');
            } else {
                $(event.currentTarget).tooltipster('close');
                switchRelease($select);
                updateTitleAttribute($select);
            }
        },

        appendNewReleaseOption = function (index, menu) {
            var $option = $(newReleaseOptionTemplate());

            $option.data('newReleaseOption', true);

            $(menu).append($option);
        },

        destroy = function() {
            $('[data-new-release-option]').remove();
        },

        setup = function (index, select) {
            appendNewReleaseOption(index, select);
            updateTitleAttribute(select);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.publishWithReleaseMenus
         */
        init = function ($scope) {
            $scope
                .find('[data-publish-with-release-menu]')
                    .addBack('[data-publish-with-release-menu]')
                    .each(setup)
                    .on('change', testNewReleaseOption)
                    .tooltipster(_.assign({}, WORKAREA.config.tooltipster, {
                        interactive: true,
                        contentAsHTML: true,
                        content: I18n.t('workarea.admin.js.publish_with_release_menus.loading'),
                        functionBefore: requestNewReleaseForm,
                        trigger: 'custom',
                        side: 'bottom'
                    }));
        };

        $(document).on('turbolinks:before-cache', destroy);

    return {
        init: init
    };
}()));
