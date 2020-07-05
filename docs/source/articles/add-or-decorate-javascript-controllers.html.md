---
title: Add or Decorate JavaScript Controllers
created_at: 2018/07/31
excerpt: "Workarea's JavaScript controllers can be decorated much like the Ruby code. This guide explains how to add or change JS code in your Workarea application as a developer."
---

# Add or Decorate JavaScript Controllers

Workarea's [JavaScript controllers](https://stimulusjs.org/reference/controllers) can be decorated much like the Ruby code. This guide explains how to add or change JS code in your Workarea application as a developer.

## Add a New JavaScript Controller

To create a new JavaScript controller, run the following generator:

    rails generate workarea:js_controller ENGINE NAME

This will create a new file at **app/javascript/${ENGINE}/controllers/${NAME}_controller.js**, with the following contents:

```javascript
import { Controller } from "stimulus"

export default class ${NAME}Controller extends Controller {
  // Add your JS functionality here.
}
```

## Decorate an Existing JavaScript Controller

To decorate an existing controller, run the following generator:

    rails generate workarea:js_decorator PATH

`PATH` should be equal to an existing controller, such as **app/javascript/workarea/storefront/flash_controller.js**. Using the aforementioned PATH as an argument will create a file in your app at **app/javasript/storefront/controllers/flash_controller.js** with the following contents:

```javascript
import FlashController from "workarea/storefront/flash_controller"

export default class extends FlashController {
  // Add method and property overrides here.
}
```

## Appendix: How Does It Work?

Workarea uses both Webpack and Stimulus to achieve a system of JavaScript code that does not need to be fully overridden in order to be extensible. Because Stimulus will load all controllers in order, and choose the most recent one when identified by a `data-controller`, as long as your application JS is loaded _after_ the JS from each gem, your local JavaScript files will always be chosen as the controllers to be used and loaded. Whereas Stimulus has a relatively open-minded approach towards loading code, Webpack does typically require explicit `import` statements in the code in order to function properly. Since this is true, a decorated controller can effectively `import` an existing controller, change some things around, and `export` the result. As long as the filename is the same and matches up with a `data-controller` in the DOM, your new controller will be used rather than the out-of-box one. The existing functionality can be preserved by extending the original controller in the class definition, carrying with it all of the methods and properties from the "base" object. This is very similar to the way [rails-decorators]() works, but it's not a complete clone since JavaScript's inheritance model is far less complex than Ruby's. That said, we've attempted to duplicate much of the same functionality from the Ruby decorators that you know and love, with some minor changes that help it fit in better in a JavaScript ecosystem.

**NOTE:** As decorating JavaScript relies heavily on the way Stimulus works, only controllers are decoratable for now. You'll have to explicitly `import` any other kinds of JS objects (like models or templates) from your local application in order to use them.
