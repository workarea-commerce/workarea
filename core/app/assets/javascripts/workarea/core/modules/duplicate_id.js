/**
 * @namespace WORKAREA.duplicateId
 */
WORKAREA.registerModule('duplicateId', (function () {
    'use strict';

    var errorMessage = function (duplicates) {
            var message = 'WORKAREA.duplicateId: ' + duplicates.length + ' ' +
                'duplicated ID attribute ' +
                WORKAREA.string.pluralize(duplicates.length, 'value') + ' ' +
                'found on page: ' + window.location.pathname;

            if (WORKAREA.environment.isTest) {
                message +=  '\n#' + duplicates.join('\n#') + '\n';
            }

            return message;
        },

        getDuplicateElements = function ($elements, duplicates) {
            return $elements.filter(function (index, element) {
                return _.includes(duplicates, element.id);
            }).toArray();
        },

        getDuplicateIds = function (ids) {
            return _.transform(_.countBy(ids), function (result, count, value) {
                if (count > 1) { result.push(value); }
            }, []);
        },

        logError = function ($elements, ids) {
            var duplicateIds = getDuplicateIds(ids),
                duplicates = getDuplicateElements($elements, duplicateIds);

            window.console.error(errorMessage(duplicates));
            _.forEach(duplicates, function (duplicate) {
                window.console.error(duplicate);
            });
        },

        throwError = function (ids) {
            var duplicates = getDuplicateIds(ids);
            throw new Error(errorMessage(duplicates));
        },

        noDuplicateIds = function (ids) {
            return _.uniq(ids).length === ids.length;
        },

        getIdValues = function ($elements) {
            return $elements.map(function (index, element) {
                return element.id;
            }).toArray();
        },

        hasIdValue = function (_, element) {
            return element.id !== '';
        },

        /**
         * @method
         * @name init
         * @memberof WORKAREA.duplicateId
         */
        init = function () {
            var $elements = $('[id]').filter(hasIdValue),
                ids = getIdValues($elements);

            if (_.isEmpty($elements) || noDuplicateIds(ids)) { return; }

            if (WORKAREA.environment.isTest) {
                throwError(ids);
            } else {
                logError($elements, ids);
            }
        };

    return {
        init: init
    };
}()));
