/**
 * @namespace WORKAREA.environment
 * @property {boolean} isTest
 * @property {boolean} isDevelopment
 * @property {boolean} isQA
 * @property {boolean} isStaging
 * @property {boolean} isProduction
 * @property {string}  current
 */
WORKAREA.registerModule('environment', (function () {
    'use strict';

    var environment = $('meta[property="environment"]').attr('content');

    return {
        isTest: environment === 'test' || _.isObject(window.Teaspoon),
        isQA: environment === 'qa',
        isDevelopment: environment === 'development',
        isStaging: environment === 'staging',
        isProduction: environment === 'production',
        current: environment
    };
}()));
