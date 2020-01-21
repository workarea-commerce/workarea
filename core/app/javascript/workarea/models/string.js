import isUndefined from "lodash.isundefined"
import isString from "lodash.isstring"

/**
 * Converts a string to lowercase and replaces all spaces width dashes.
 *
 * @param  {String} string
 * @return {String} the dasherized string
 */
export function dasherize(string) {
    return string.replace(/\s+/g, '-').toLowerCase();
}

/**
 * Pluralizes a string, based on a given count.
 *
 * @param  {Integer} count - The number that determines pluralization
 * @param  {String} string - string to pluralized
 * @param  {String} pluralizedString - optional, overrides pluralized
 *                  result of the function
 * @return {String} the pluralized string
 */
export function pluralize(count, string, pluralizedString) {
    if (count > 1 && ! isUndefined(pluralizedString)) {
        return pluralizedString;
    } else if (count > 1) {
        return string + 's';
    } else {
        return string;
    }
}

/**
 * @method
 * @name titleize
 * @memberof WORKAREA.string
 */
export function titleize(string) {
  if ( ! isString(string)) {
      throw new Error('WORKAREA.string.titleize: expecting string');
  }

  return trim(string).toLowerCase().split(' ').map(subString => {
    return subString.charAt(0).toUpperCase() + subString.slice(1)
  }).join(' ')
}

export default { dasherize, pluralize, titleize }
