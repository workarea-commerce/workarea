/**
 * @namespace WORKAREA.string
 */
WORKAREA.registerModule('string', (function () {
    'use strict';

    var

        /**
         * Converts a string to lowercase and replaces all spaces width dashes.
         *
         * @param  {String} string
         * @return {String} the dasherized string
         */
        dasherize = function (string) {
            return string.replace(/\s+/g, '-').toLowerCase();
        },

        /**
         * Pluralizes a string, based on a given count.
         *
         * @param  {Integer} count - The number that determines pluralization
         * @param  {String} string - string to pluralized
         * @param  {String} pluralizedString - optional, overrides pluralized
         *                  result of the function
         * @return {String} the pluralized string
         */
        pluralize = function (count, string, pluralizedString) {
            if (count > 1 && ! _.isUndefined(pluralizedString)) {
                return pluralizedString;
            } else if (count > 1) {
                return string + 's';
            } else {
                return string;
            }
        },

        /**
         * @method
         * @name titleize
         * @memberof WORKAREA.string
         */
        titleize = function (string) {
            if ( ! _.isString(string)) {
                throw new Error('WORKAREA.string.titleize: expecting string');
            }

            return _.map(
               $.trim(string).toLowerCase().split(' '),
               function (subString) {
                   return subString.charAt(0).toUpperCase() +
                          subString.slice(1);
               }
           ).join(' ');
        };

    return {
        titleize: titleize,
        pluralize: pluralize,
        dasherize: dasherize
    };
}()));
