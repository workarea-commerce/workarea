(function () {
    'use strict';

    // Turn off transformations and transitions in the test environment, as they
    // cause timing issues for build teams.
    feature.css3Dtransform = false;
    feature.cssTransform = false;
    feature.cssTransition = false;

    // Make sure the browser doesn't think it'll be poked.
    feature.touch = false;

    window.alert = function () {};
    window.confirm = function () { return true; };
}());
