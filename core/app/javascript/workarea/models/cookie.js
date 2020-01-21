/**
 * Manages the handling of cookies.
 *
 * Adapted from {@link http://www.quirksmode.org/js/cookies.html}
 *
 * @namespace cookie
 */

export function trimAndSplit(string) {
  var subject = $.trim(string),
      suffix = subject.substring(subject.indexOf('=')),
      cookie = subject.replace(suffix, ''),
      value = suffix.substring(1);

  return [cookie, value];
}
        },

        /**
         * @method
         * @name create
         * @memberof WORKAREA.cookie
         */
        create = function (name, value, days) {
            var date,
                expires;

            if (days) {
                date = new Date();
                date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
                expires = '; expires=' + date.toGMTString();
            } else {
                expires = '';
            }

            document.cookie = name + '=' + value + expires + '; path=/';
        },

        /**
         * @method
         * @name destroy
         * @memberof WORKAREA.cookie
         */
        destroy = function (name) {
            document.cookie = name + '=;expires=Thu, 01 Jan 1970 00:00:00 GMT;path=/';
        },

        /**
         * @method
         * @name read
         * @memberof WORKAREA.cookie
         */
        read = function (name) {
            return _.fromPairs(
                _.map(document.cookie.split(';'), trimAndSplit)
            )[name] || null;
        };

    return {
        create: create,
        destroy: destroy,
        read: read
    };
}()));
