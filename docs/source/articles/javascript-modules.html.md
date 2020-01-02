---
title: JavaScript Modules
created_at: 2018/07/31
excerpt: Workarea JavaScript modules are used to solve the problems of code organization and asynchronous initialization. First let's look at the issue of code organization so I can explain what I mean by "module".
---

# JavaScript Modules

Workarea JavaScript modules are used to solve the problems of code organization and asynchronous initialization. First let's look at the issue of code organization so I can explain what I mean by "module".

## Organizing Code

JavaScript modules in the Workarea platform are simply named objects registered via `WORKAREA.registerModule`. Each module acts as a namespace for a collection of related functions. To create a module, start with an object. In the example below, I've assigned the object to a variable.

```
var obj = {
    doSomething: function () {
        // code to do something
    },
    doSomethingElse: function () {
        // code to do somethinf else
    }
};
```

To make this object a module, simply register it, giving it a name in the process. The name must be a valid JavaScript identifier.

```
WORKAREA.registerModule('demoModule', obj);
```

You can now access the module's methods using `WORKAREA.demoModule`.

```
WORKAREA.demoModule.doSomething();
WORKAREA.demoModule.doSomethingElse();
```

**Note:** Module names are guaranteed to be unique. If you try to register another module with the same name, an error will be thrown.

### Module Patterns

In practice, modules are not created using the pattern shown above. Instead, a function is created and immediatedly invoked to return the object passed to `WORKAREA.registerModule`. This allows you to program within the body of a function rather than within the body of an object but still return an object in the end.

```
WORKAREA.registerModule('demoModule', (function () {
    var doSomething = function () {
            // code to do something
        },

        doSomethingElse = function () {
            // code to do something else
        };

    return {
        doSomething: doSomething,
        doSomethingElse: doSomethingElse
    };
}()));
```

A secondary benefit of this pattern is private methods. The returned object includes only the methods that are considered public.

```
WORKAREA.registerModule('demoModule', (function () {
    var doSomethingPrivately = function () {
            // code to do something privately
        },

        doSomethingElsePrivately = function () {
            // code to do something else privately
        },

        doSomething = function () {
            // code to do something that may invoke
            // doSomethingPrivately()
            // or
            // doSomethingElsePrivately()
        },

        doSomethingElse = function () {
            // code to do something else that may invoke
            // doSomethingPrivately()
            // or
            // doSomethingElsePrivately()
        };

    return {
        doSomething: doSomething,
        doSomethingElse: doSomethingElse
    };
}()));
```

```
WORKAREA.demoModule.doSomething(); // does something
WORKAREA.demoModule.doSomethingElse(); // does something else
WORKAREA.demoModule.doSomethingPrivately(); // undefined (private)
WORKAREA.demoModule.doSomethingElsePrivately(); // undefined (private)
```

### Method Naming Conventions

Public module methods generally fall into 2 categories: utilities and DOM manipulations. Utilities are methods like `WORKAREA.url.parse` that transform input into output and generally have no interaction with the DOM. On the other hand, **modules that manipulate the DOM always include a public method named `init` which is responsible for querying the DOM for the relevant elements**. This convention is important to ensure proper module initialization, which I explain next.

## Initializing Code

The 2nd problem modules address is code initialization, specifically asynchronous initialization. But first let's look at synchronous initialization.

The [application manifest](/articles/add-javascript-through-a-manifest.html) uses `require_asset` to load each JavaScript module into memory. At that point, each method on each module is defined, but none have yet been invoked. The manifest concludes by invoking a single JavaScript method:

```
WORKAREA.initModules($(document));
```

`WORKAREA.initModules` enumerates each registered module, in the order in which they were registered (the order in which they are included in the manifest) and invokes each module's `init` method if it has one. `$(document)`, the argument passed to `WORKAREA.initModules` is passed through to each module's `init` method when it is invoked.

This is the first time in the application that `WORKAREA.initModules` is called and the only time that it is called with a reference to the entire document as its argument. It may get called many more times before the page is reloaded, so **modules must be written to run multiple times and must be aware of their current scope**. The current scope is a DOM reference passed as an argument, which is covered next.

### Module Scope

**Scope is the most important concept in the Workarea module system.** It's easiest to explain scope through an example. Consider a module that implements the following methods:

```
var updateProductDetails = function (event) {
        // asynchronously request a new DOM fragment with up to date
        // product details and replace the current page's product
        // details fragment with the new one
    },

    init = function ($scope) {
        $('.change-color-button', $scope).on('click', updateProductDetails);
    };
```

As explained above, the application manifest will invoke this module's `init` method, passing `$(document)` as the argument named `$scope`. The `init` method queries within `$scope`, in this case the entire document, for elements matching the selector `.change-color-button` and attaches a click handler to each. When clicked, the `updateProductDetails` method, shown above, is invoked.

So every change-color button has now been wired up with a click handler to replace the product details. Now the user clicks one of them. An ajax request is made to fetch new product details HTML and that HTML replaces the old product details HTML on the current page. However, the new HTML includes some change-color buttons and they don't have the click handler attached because they weren't present when modules were initialized the first time around. Same goes for the product zoom and any other JavaScript functionality that's supposed to happen within the new product details.

To fix this, the `updateProductDetails` method must call `WORKAREA.initModules` and pass in the new HTML as the `$scope` so that **modules are initialized again, but only within the new fragment that was added to the DOM**. It is important to not re-init modules on any part of the DOM other than the new fragment to avoid bugs from double event bindings and similar issues.

```
var updateProductDetails = function (event) {
        // asynchronously request a new DOM fragment with up to date
        // product details and replace the current page's product
        // details fragment with the new one. store the new DOM
        // fragment in the variable $newProductDetails for reference

        WORKAREA.initModules($newProductDetails);
    },

    init = function ($scope) {
        $('.change-color-button', $scope).on('click', updateProductDetails);
    };
```

**Every init function must therefore accept a `$scope` argument and must always limit its DOM queries to within that scope.**

**Note:** Code that should run only once (like attaching a resize handler to `window`) should generally be run outside of an init function since init functions may be invoked multiple times. If the code must be run inside an init function (to test for a specific element within `$scope`, for example), programatically restrict the function to run only once using something like `_.once`.

## Customizing a Module

To customize an existing module you must [override](/articles/overriding.html) it, essentially making a copy of it in your application.

## Creating a Module

To create a new module, run the workarea:js\_module Rails generator within your application. This will generate the file and the module boilerplate, which you can then customize to taste.

Run the generator without any arguments to display its documentation.

```
cd path/to/your_app
bin/rails g workarea:js_module
```

