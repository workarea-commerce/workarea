/**
 * @namespace WORKAREA.lazyImages
 */
WORKAREA.registerModule('lazyImages', (function () {
    'use strict';

    var events = _.map(
            ['scroll', 'resize', 'orientationChange'],
            function (name) { return name + '.lazyImages'; }
        ),

        loadImage = function (image) {
            var $image = $(image),
                src = $image.data('lazyImage');

            $image.removeAttr('data-lazy-image');

            WORKAREA.image.get(src, $image).done(function ($loadedImage) {
                $image.replaceWith($loadedImage);
                $image.addClass('lazy-image--loaded');
            });
        },

        imageInViewport = function (image) {
            var rect = image.getBoundingClientRect(),
                windowHeight = (
                    window.innerHeight || document.documentElement.clientHeight
                ),
                windowWidth = (
                    window.innerWidth || document.documentElement.clientWidth
                ),
                yInView = (
                    (rect.top <= windowHeight) && (rect.top + rect.height >= 0)
                ),
                xInView = (
                    (rect.left <= windowWidth) && (rect.left + rect.width >= 0)
                );

            return (yInView && xInView);
        },

        lazyLoad = _.debounce(function () {
            $('[data-lazy-image]').each(function (index, image) {
                if (imageInViewport(image)) { loadImage(image); }
            });
        }, 20),

        init = function ($scope) {
            if (_.isEmpty($scope.find('[data-lazy-image]'))) { return; }
            $(window).trigger(events[0]);
        };

    $(window).on(events.join(' '), lazyLoad);

    return {
        init: init,
        lazyLoad: lazyLoad,
        loadImage: loadImage
    };
}()));
