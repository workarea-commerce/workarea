(function () {
    'use strict';

    var modules = [],

        safeEnvironment = function () {
            var environment = $('meta[property=environment]').attr('content');
            return environment === 'test' || environment === 'development';
        };

    /**
     * @namespace WORKAREA
     */
    window.WORKAREA = window.WORKAREA || {};

    /**
     * @method
     * @name registerModule
     * @memberof WORKAREA
     */
    window.WORKAREA.registerModule = function (name, module) {
        if (_.has(WORKAREA, name)) {
            throw new Error(
                'WORKAREA.registerModule: Module `' + name + '` already exists.'
            );
        }

        window.WORKAREA[name] = module;

        modules.push(module);
    };

    /**
     * @method
     * @name initModules
     * @memberof WORKAREA
     */
    window.WORKAREA.initModules = function ($scope) {
        if ($scope instanceof jQuery === false) {
            throw new Error(
                'WORKAREA.initModules: ' +
                '$scope is required and must be a jQuery Object'
            );
        }

        if ($scope.data('modulesInitialized') && safeEnvironment()) {
            var html;
            if ($scope.is(document)) {
                html = 'document';
            } else {
                html = $scope.prop('outerHTML').split('>')[0] + '>';
            }
            throw new Error(
                'WORKAREA.initModules: ' +
                'You have already initialized modules on this $scope: ' + html
            );
        }

        $scope.data('modulesInitialized', true);

        _.invokeMap(_.filter(modules, 'init'), 'init', $scope);
    };
}());
