/**
 * @namespace WORKAREA.url
 */
WORKAREA.registerModule('url', (function () {
    'use strict';

    /**
     * Adapted from parseUri 1.2.2 by Steven Levithan
     * @method
     * @name parse
     * @memberof WORKAREA.url
     */
    var parse = function (urlString) {
            var o = {
                    strictMode: false,
                    key: ['source', 'protocol', 'authority', 'userInfo', 'user', 'password', 'host', 'port', 'relative', 'path', 'directory', 'file', 'query', 'anchor'],
                    q: {
                        name: 'queryKey',
                        parser: /(?:^|&)([^&=]*)=?([^&]*)/g
                    },
                    parser: {
                        strict: /^(?:([^:/?#]+):)?(?:\/\/((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:/?#]*)(?::(\d*))?))?((((?:[^?#/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/,
                        loose:  /^(?:(?![^:@]+:[^:@/]*@)([^:/?#.]+):)?(?:\/\/)?((?:(([^:@]*)(?::([^:@]*))?)?@)?([^:/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#/]*\.[^?#/.]+(?:[?#]|$)))*\/?)?([^?#/]*))(?:\?([^#]*))?(?:#(.*))?)/
                    }
                },
                m = o.parser[o.strictMode ? 'strict' : 'loose'].exec(urlString),
                uri = {},
                i = 14;

            // jshint plusplus:false
            while (i--) { uri[o.key[i]] = m[i] || ''; }

            uri[o.q.name] = {};
            uri[o.key[12]].replace(o.q.parser, function ($0, $1, $2) {
                var paramName;

                if (_.isEmpty($1)) { return; }

                $1 = window.decodeURIComponent($1);

                if (_.endsWith($1, '[]')) {
                    paramName = $1.split('[]')[0];
                    uri[o.q.name][paramName] = uri[o.q.name][paramName] || [];
                    uri[o.q.name][paramName].push($2);
                } else {
                    uri[o.q.name][$1] = $2;
                }
            });

            return uri;
        },

        /**
         * @method
         * @name addQuery
         * @memberof WORKAREA.url
         */
        addQuery = function (url, queryString) {
            return [url, queryString].join('?');
        },

        /**
         * @method
         * @name addQuery
         * @memberof WORKAREA.url
         */
        addToQuery = function (url, queryToAppend) {
            if (_.includes(url, '?')) {
                return [url, queryToAppend].join('&');
            } else {
                return addQuery(url, queryToAppend);
            }
        },

        /**
         * @method
         * @name removeQuery
         * @memberof WORKAREA.url
         */
        removeQuery = function (url) {
            return url.split('?')[0];
        },

        /**
         * @method
         * @name replaceQuery
         * @memberof WORKAREA.url
         */
        replaceQuery = function (url, queryString) {
            return addQuery(removeQuery(url), queryString);
        },

        /**
         * @method
         * @name current
         * @memberof WORKAREA.url
         */
        current = function () {
            return window.location.href;
        },

        /**
         * @method
         * @name redirect
         * @memberof WORKAREA.url
         */
        redirectTo = function (url) {
            window.location = url;
        },

        /**
         * @method
         * @name updateParams
         * @memberof WORKAREA.url
         */
        updateParams = function (url, params) {
            var parsed = parse(url),
                keys = Object.keys(params);

            _.forEach(keys, function(key) {
                parsed.queryKey[key] = params[key];
            });

            return replaceQuery(url, $.param(parsed.queryKey));
        };

    return {
        parse: parse,
        addQuery: addQuery,
        addToQuery: addToQuery,
        removeQuery: removeQuery,
        replaceQuery: replaceQuery,
        current: current,
        redirectTo: redirectTo,
        updateParams: updateParams
    };
}()));
