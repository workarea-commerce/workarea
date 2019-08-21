/**
 * @namespace WORKAREA.transitionEvents
 */
WORKAREA.registerModule('transitionEvents', (function () {
    'use strict';

    var EVENT_NAME_MAP = {
            transitionend: {
                'transition': 'transitionend',
                'WebkitTransition': 'webkitTransitionEnd',
                'MozTransition': 'mozTransitionEnd',
                'OTransition': 'oTransitionEnd',
                'msTransition': 'MSTransitionEnd'
            },

            animationend: {
                'animation': 'animationend',
                'WebkitAnimation': 'webkitAnimationEnd',
                'MozAnimation': 'mozAnimationEnd',
                'OAnimation': 'oAnimationEnd',
                'msAnimation': 'MSAnimationEnd'
            }
        },

        endEvents = [],

        /**
         * Adapted from {@link https://gist.github.com/foolyoghurt/b76988ef05fbeaaf04ae}
         * @method
         * @name detect
         * @memberof WORKAREA.transitionEvents
         */
        detect = function () {
            var testEl = document.createElement('div'),
                style = testEl.style;

            if (!_.isEmpty(endEvents)) {
                return endEvents.join(' ');
            }

            // On some platforms, in particular some releases of Android 4.x,
            // the un-prefixed "animation" and "transition" properties are defined on the
            // style object but the events that fire will still be prefixed, so we need
            // to check if the un-prefixed events are useable, and if not remove them
            // from the map
            if (!('AnimationEvent' in window)) {
                delete EVENT_NAME_MAP.animationend.animation;
            }

            if (!('TransitionEvent' in window)) {
                delete EVENT_NAME_MAP.transitionend.transition;
            }

            for (var baseEventName in EVENT_NAME_MAP) {
                var baseEvents = EVENT_NAME_MAP[baseEventName];

                for (var styleName in baseEvents) {
                    if (styleName in style) {
                        endEvents.push(baseEvents[styleName]);
                        break;
                    }
                }
            }

            return endEvents.join(' ');
        };

    return {
        detect: detect
    };
}()));
