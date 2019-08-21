---
title: Automated JavaScript Testing
created_at: 2018/09/17
excerpt: The Workarea platform uses Teaspoon to unit test JavaScript modules.
---

# Automated JavaScript Testing

## Overview

The Workarea platform uses [Teaspoon](https://github.com/modeset/teaspoon) to unit test JavaScript modules.

The tests themselves are written using the [Mocha](https://github.com/mochajs/mocha) test framework. [Chai](http://chaijs.com/) is the chosen assertion library. Specifically, [Chai's Expect style](http://chaijs.com/guide/styles/#expect) is used in an attempt to achieve parity with RSpec.

Lastly, Workarea uses [Sinon](http://sinonjs.org/) via [Sinon Chai](https://github.com/domenic/sinon-chai) which provides test spies, mocks, and stubs.

## When should a Teaspoon test be written?

The platform's JavaScript modules are written using [The Revealing Module Pattern](https://carldanley.com/js-revealing-module-pattern/). If a module publicly exposes a method that method then becomes testable. The majority of the platform's modules, however, initialize only when an element with a specific selector is found within a given scope. These modules provide functionality for general use or for a specific feature are less straight forward to test.

### Utility Modules

If a module is written with many useful public methods it becomes an ideal Teaspoon test candidate. An example of this is the `WORKAREA.dialog` module. This module is written to be almost entirely public facing, deferring a lot of the interactive functionality to other modules who make use of its API.

### General Purpose Modules

If a general-use, DOM-based module is written then a fixture can be used as the method's scope. This way you are able to assert that the module functions properly within the vacuum that is the fixture. An example of this type of module would be the `WORKAREA.dialogButtons` module, which searches a given scope for an element with a `data-dialog-button` attribute before providing its functionality to said element.

### Broken Code

If a JavaScript bug is uncovered during QA, a Teaspoon test should be written to prove that the bug exists before the code is updated. This ensures that the bug has actually been fixed and will not resurface again.

## Feature Tests v. Unit Tests

For complex features, such as the content editing feature of the Admin, there is a large amount of JavaScript required to make the feature function properly. When writing Teaspoon tests for these types of modules keep in mind that you aren't using Teaspoon to test the feature itself, but how the methods provided by the module interact with the page.

It should be noted that feature tests require that the entire application be spun up each time the suite is run, so they should only be written to describe and verify high-level features. Unit tests do not require the entire application and are therefore much quicker. If you can provide adequate test coverage using unit tests, you should do so.

## Examples

Let's look at a few samples directly from the Workarea source code.

### The `WORKAREA.string` Utility Module

```
WORKAREA.registerModule('string', (function () {
    'use strict';

    var pluralize = function (count, string, pluralizedString) {
            if (count > 1 && ! _.isUndefined(pluralizedString)) {
                return pluralizedString;
            } else if (count > 1) {
                return string + 's';
            } else {
                return string;
            }
        },

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
        pluralize: pluralize
    };
}()));
```

As you can see, the `WORKAREA.string` module has two public methods, `titleize` and `pluralize`. Each one of these methods function as a utility for other modules to use and, therefore, should be tested to ensure they are working properly:

```
describe('WORKAREA.string', function () {
    describe('titleize', function () {
        it('titleizes a given string', function () {
            expect(WORKAREA.string.titleize('foo ')).to.equal('Foo');
            expect(WORKAREA.string.titleize('BAR')).to.equal('Bar');
            expect(WORKAREA.string.titleize('fOoBaR')).to.equal('Foobar');
        });
    });

    describe('pluralize', function () {
        it('returns a custom pluralized string', function () {
            expect(WORKAREA.string.pluralize(2, 'baz', 'bazes')).to.equal('bazes');
        });

        it('returns a simple pluralized string', function () {
            expect(WORKAREA.string.pluralize(2, 'bar')).to.equal('bars');
        });

        it('returns an unpluralized string', function () {
            expect(WORKAREA.string.pluralize(1, 'foo')).to.equal('foo');
        });
    });
});
```

### The `WORKAREA.helpTooltips` Global Module

```
WORKAREA.registerModule('helpTooltips', (function () {
    'use strict';

    var initTooltip = function (init, link) {
            var fragmentId = $(link).attr('href'),
                options = $(link).data('helpTooltip') || {};

            $(link).tooltipster(_.assign({ content: $(fragmentId) }, options));
        },

        init = function ($scope) {
            $('[data-help-tooltip]', $scope).each(initTooltip);
        };

    return {
        init: init
    };
}()));
```

This module is responsible for creating an instance of jQuery Tooltipster for each element within the given <coder>$scope that has a <code>data-help-tooltip</code> attribute.</coder>

Create the fixture that meets these requirements:

```
= link_to 'Tooltip', '#help-tooltip', id: 'help-link', data: { help_tooltip: '' }
#help-tooltip.help-tooltip
  %p Tooltip content.
```

And use the fixture as the aforementioned `$scope` when testing the module:

```
describe('WORKAREA.helpTooltips', function () {
    describe('init', function () {
        it('inits tooltipster on the link', function () {
            this.fixtures = fixture.load('help_tooltip.html', true);

            sinon.spy($.prototype, 'tooltipster');

            WORKAREA.helpTooltips.init($(this.fixtures));

            expect($.fn.tooltipster.calledOnce).to.equal(true);

            $.fn.tooltipster.restore();
        });
    });
});
```

Notice that there are no tests asserting that jQuery Tooltipster itself is working properly. Since the platform depends on this 3rd party plugin, and the plugin ships with it's own tests, we simply need to ensure that jQuery Tooltipster is being instantiated under the right conditions.


