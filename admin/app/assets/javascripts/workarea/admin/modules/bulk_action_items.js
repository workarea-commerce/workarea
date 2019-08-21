/**
 * @namespace WORKAREA.bulkActionItems
 */
WORKAREA.registerModule('bulkActionItems', (function () {
    'use strict';

    var hiddenInput = JST['workarea/core/templates/hidden_input'],
        countUI = JST['workarea/admin/templates/bulk_action_items_count'],

        storage = window.sessionStorage,


        //
        // Utility
        buildInputGroup = function (collection, group) {
            return _.map(collection, function (value) {
                var result = hiddenInput({ name: group + '[]', value: value });
                return $(result).data('addedByBulkActionItem', true);
            });
        },


        //
        // Session
        removeSession = function () {
            storage.removeItem('bulkActionItems');
        },

        setSession = function (state) {
            storage.setItem('bulkActionItems', JSON.stringify(state));
        },

        /**
         * @method
         * @name getSession
         * @memberof WORKAREA.bulkActionItems
         */
        getSession = function () {
            return JSON.parse(storage.getItem('bulkActionItems'));
        },

        initSession = _.once(setSession),

        setup = function ($scope) {
            var state = {}, initialCount;

            initialCount = $('[data-browsing-controls-count]', $scope).data(
                'browsingControlsCount'
            );

            state.ids = [];
            state.count = 0;
            state.excludeIds = [];
            state.includeAll = false;
            state.pathname = window.location.pathname;
            state.initialCount = initialCount;
            initSession(state);

            return state;
        },

        sessionApplicable = function () {
            var session = getSession();
            return session && session.pathname === window.location.pathname;
        },


        //
        // State Management
        toggleSelectAll = function (scope, session) {
            var $selectAll = $('[data-bulk-action-select-all]', scope),
                $selectAllCheckbox = $selectAll.closest('.checkbox'),
                allSelected = session.count === session.initialCount;

            if (allSelected) {
                $selectAll.prop('checked', true);
            } else {
                $selectAll.prop('checked', false);
            }

            if (session.count === 0) {
                $selectAllCheckbox.removeClass('checkbox--indeterminate');
            } else {
                $selectAllCheckbox.addClass('checkbox--indeterminate');
            }
        },

        toggleCountUI = function ($ui, count) {
            var $parent = $ui.parent();

            if (count > 0) {
                $parent.removeClass('hidden');
            } else if (count <= 0) {
                $parent.addClass('hidden');
            }
        },

        setCount = function (scope, count) {
            var $ui = $('[data-bulk-action-item-count]', scope);

            if (_.isEmpty($ui)) {
                var $placeholder = $('[data-bulk-action-count-placeholder]', scope),
                    $countUI = $(countUI({ count: count }));

                if (count <= 0) {
                    $countUI.addClass('hidden');
                }

                $placeholder.replaceWith($countUI);
            } else {
                $ui.text(count);
            }

            toggleCountUI($ui, count);
        },

        reset = function ($scope) {
            var $selectAll, $itemInputs, $count, $forms;

            $scope = ($scope instanceof jQuery) ? $scope : $(document);
            $selectAll = $('[data-bulk-action-select-all]', $scope),
            $itemInputs = $('[data-bulk-action-item]', $scope);
            $count = $('[data-bulk-action-item-count]', $scope);
            $forms = $('[data-bulk-action-form]', $scope);

            $selectAll.prop('checked', false);
            $itemInputs.prop('checked', false);

            $count.text($count.data('bulkActionItemCount'));

            $('input', $forms).filter(function(index, input) {
                return $(input).data('addedByBulkActionItem');
            }).remove();
        },

        destroy = _.flow(reset, removeSession),

        recall = function ($scope) {
            var session = getSession(),
                $selectAll = $('[data-bulk-action-select-all]', $scope),
                $itemInputs = $('[data-bulk-action-item]', $scope),

                selectedItems = function (index, item) {
                    return _.includes(session.ids, item.value);
                },

                itemsNotExcluded = function (index, item) {
                    return ! _.includes(session.excludeIds, item.value);
                };

            if (session.includeAll) {
                $selectAll.prop('checked', true);

                if (_.isEmpty(session.excludeIds)) {
                    $itemInputs.prop('checked', true);
                } else {
                    $itemInputs.filter(itemsNotExcluded).prop('checked', true);
                }
            } else {
                if ( ! _.isEmpty(session.ids)) {
                    $itemInputs.filter(selectedItems).prop('checked', true);
                }
            }

            setCount($scope, session.count);
        },


        //
        // Bootstrap
        removeAll = function (event, session) {
            var $itemInputs =
                    $(event.target)
                        .closest('table')
                            .find('[data-bulk-action-item]');

            $itemInputs.prop('checked', false);

            session.ids = [];
            session.excludeIds = [];
            session.includeAll = false;
            session.count = 0;

            return session;
        },

        addAll = function (event, session) {
            var $itemInputs =
                    $(event.target)
                        .closest('table')
                            .find('[data-bulk-action-item]');

            $itemInputs.prop('checked', true);

            session.ids = [];
            session.excludeIds = [];
            session.includeAll = true;
            session.count = session.initialCount;

            return session;
        },

        remove = function (event, session) {
            if (session.includeAll) {
                session.excludeIds.push(event.target.value);
            } else {
                _.remove(session.ids, function (id) {
                    return id === event.target.value;
                });
            }

            session.count -= 1;

            return session;
        },

        add = function (event, session) {
            if (session.includeAll) {
                _.remove(session.excludeIds, function (id) {
                    return id === event.target.value;
                });
            } else {
                session.ids.push(event.target.value);
            }

            session.count += 1;

            return session;
        },


        //
        // Event Handlers
        handleButtons = function (event) {
            var session = getSession(), idInputs, excludeIdsInputs;

            if (_.isNull(session)) { return; }

            idInputs = buildInputGroup(session.ids, 'ids'),
            excludeIdsInputs = buildInputGroup(session.excludeIds, 'exclude_ids');

            _.each(idInputs.concat(excludeIdsInputs), function($input) {
                $input.appendTo(event.target);
            });

            removeSession();
        },

        handleSelectAll = function (event) {
            var session = getSession() || setup(),
                $selectAll = $(event.target).parent('.checkbox'),
                wasChecked = event.target.checked,
                someSelected = $selectAll.is('.checkbox--indeterminate'),
                allSelected = session.count === session.initialCount,
                shouldSelectAll;

            event.preventDefault();

            if (wasChecked) {
                if (someSelected || allSelected) {
                    shouldSelectAll = false;
                } else {
                    shouldSelectAll = true;
                }
            } else {
                shouldSelectAll = false;
            }

            if (shouldSelectAll) {
                session = addAll(event, session);
                $(event.target).prop('checked', true);
            } else {
                session = removeAll(event, session);
                $(event.target).prop('checked', false);
            }

            setSession(session);
            toggleSelectAll(event.delegateTarget, session);
            setCount(event.delegateTarget, session.count);
        },

        handleItems = function (event) {
            var session = getSession() || setup();

            if (event.target.checked) {
                session = add(event, session);
            } else {
                session = remove(event, session);
            }

            setSession(session);
            toggleSelectAll(event.delegateTarget, session);
            setCount(event.delegateTarget, session.count);
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.bulkActionItems
         */
        init = function ($scope) {
            $scope
            .on('change', '[data-bulk-action-item]', handleItems)
            .on('change', '[data-bulk-action-select-all]', handleSelectAll)
            .on('submit', '[data-bulk-action-form]', handleButtons)
                .find('.browsing-controls')
                .on('click', 'a', removeSession)
                .on('submit', 'form', removeSession);

            sessionApplicable() ? recall($scope) : destroy($scope);
        };

    $(document).on('turbolinks:before-cache', reset);

    return {
        init: init,
        getSession: getSession
    };
}()));
