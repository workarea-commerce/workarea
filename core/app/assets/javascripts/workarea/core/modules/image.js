/**
 * @namespace WORKAREA.image
 */
WORKAREA.registerModule('image', (function () {
    'use strict';

    /**
     * @method
     * @name get
     * @memberof WORKAREA.image
     */
    var get = function (src, $existingImage) {
            var $image = ($existingImage || $('<img />')),
                gettingImage = $.Deferred(),
                argumentArray = _.toArray(arguments),

                resolvePromise = function () {
                    argumentArray.unshift($image);
                    gettingImage.resolve.apply(null, argumentArray);
                },

                rejectPromise = function () {
                    gettingImage.reject(argumentArray);
                };

            if (_.isUndefined(src)) {
                rejectPromise();
            }

            argumentArray.shift();

            $image
            .attr('src', src)
            .on('load', resolvePromise)
            .on('error', rejectPromise);

            return gettingImage.promise();
        };

    return {
        get: get
    };
}()));
