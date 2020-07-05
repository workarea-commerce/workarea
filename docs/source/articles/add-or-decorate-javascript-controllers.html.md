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
