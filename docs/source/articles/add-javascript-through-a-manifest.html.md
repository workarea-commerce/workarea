---
title: Add JavaScript through a Manifest
created_at: 2018/07/31
excerpt: JavaScript manifests are the preferred solution for adding JavaScripts to and removing JavaScripts from a Workarea application. The Workarea Storefront includes 2 manifests, head and application, which are introduced in the JavaScript overview, wherea
---

# Add JavaScript through a Manifest

JavaScript manifests are the preferred solution for adding JavaScripts to and removing JavaScripts from a Workarea application. The Workarea Storefront includes 2 manifests, **head** and **application** , which are introduced in the [JavaScript overview](/articles/javascript-overview.html), whereas the Admin includes only an **application** manifest. This guides covers them in detail.

If you're new to Ruby on Rails and the concept of asset manifests, check out the following guides to get you started.

- [Rails Asset Manifests](/articles/rails-asset-manifests.html)
- [Rails Asset View Helpers](/articles/rails-asset-view-helpers.html)

## Customizing a Manifest

To add and remove JavaScript through a manifest, you need to have a copy of the manifest in your app. If you're working in a new application, start by [overriding](/articles/overriding.html) the manifest file you want to customize. You can override a manifest in the same way as any other JavaScript file. When overriding, note that the manifest files end with the extensions `.js.erb`. I'll explain the reason for that in the following sections which look at the head and application manifests in detail.

Now that you have a copy of the manifest in your app, edit it to taste. The follow sections explain how Workarea manifests differ from default Rails manifests and what is included out of the box.

## Storefront's Head Manifest

In the Storefront, the head manifest is loaded in the document `head` and generally blocks the rest of the page from loading. It should therefore be kept as light as possible. Include only those scripts that must execute before the DOM is ready (like Feature.js) or those that must execute as soon as possible (like analytics).

The Storefront's head manifest looks something like this:

workarea-storefront/app/assets/javascripts/workarea/storefront/head.js.erb:

```ruby
<%
  # Feature.js
  require_asset 'featurejs_rails/feature'
  # Test Helper
  require_asset 'workarea/core/feature_test_helper' if Rails.env.test?
%>

// apply Feature.js classes to the root HTML element
window.feature.testAll();

<%
  # Plugin Head Append Point
  append_javascripts('storefront.head')
%>
```

Unlike a [standard Rails manifest](/articles/rails-asset-manifests.html) there are no directives. Instead, the is a mix of method calls and ERB blocks, hence the need for the `.erb` file extension mentioned above. The manifest is designed as such to support the Workarea plugin system and to load some assets conditionally, as you'll see shortly.

Let's work down the manifest, line by line.

### Feature.js

The first called method, `require_asset`, is provided by the Rails asset pipeline and is equivalent to the directive `//= require` seen in a [standard Rails manifest](/articles/rails-asset-manifests.html). In this case, it is including the Feature.js library, whose path is determined by the featurejs\_rails gem. In some ways, Feature.js is different from the other dependencies bundled with Workarea, which is explained in the [Feature.js and Feature Test Helper](/articles/featurejs-and-feature-spec-helper.html) guide.

### Feature Test Helper

Next up is feature\_test\_helper, which is—you guessed it—also explained in the [Feature.js and Feature Test Helper](/articles/featurejs-and-feature-spec-helper.html) guide. The path to feature\_test\_helper indicates it lives in the workarea-core gem. Workarea assets shared between workarea-admin and workarea-storefront are kept in workarea-core.

### Running Feature.js Tests

The purpose of Feature.js is to detect which newer browser APIs are at the developer's disposal. It provides its own API that allows a developer to "test" if a feature is available or not in their JavaScript code, but that all happens when Feature.js is included on the first line. This line runs all of the tests and adds classes to the root HTML element of the document, allowing a developer to progressively enhance their application at the CSS level. It is loaded in this order because the Feature Test Helper disables some features, like CSS animations and transformations, which make an application more difficult to write system tests against.

### Plugin JavaScripts

Next is a call to `append_javascripts`. This method is defined by Workarea and is used to load JavaScripts from Workarea plugins. See [Appending](/articles/appending.html) for a full explanation, but in short, plugins may be configured to insert their JavaScript files here.

## Storefront's Application Manifest

Moving on to the application manifest, in contrast to the head manifest, it is loaded at the end of the document `body`, it does not block the page from rendering, and is used for scripts that can or should be deferred until the DOM is ready. Because the DOM is ready when the application manifest is executed, scripts included in this manifest are not wrapped in a "on ready" handler.

Like the head manifest, the application manifest is essentially one big ERB block, with the exception of a single line of executable JavaScript code at the end. The application manifest is composed of multiple thematic sections. "Zoomed out", it looks something like this:

workarea-storefront/app/assets/javascripts/workarea/storefront/application.js.erb:

```
<%

  # require dependencies
  # append plugin dependencies

  # require templates
  # append plugin templates

  # require custom jquery ui widgets

  # require workarea's module controller

  # require configuration
  # append plugin configuration

  # require routes

  # require modules
  # append plugin modules

%>

WORKAREA.initModules($(document));
```

Now let's zoom in on each of the manifest sections.

### Dependencies

```ruby
# Library Dependencies
%w(
  webcomponentsjs-rails/MutationObserver
  i18n
  i18n/translations
  local_time
  lodash
  jquery3
  jquery-ui/core
  jquery-ui/widget
  jquery-ui/position
  jquery-ui/widgets/mouse
  jquery-ui/widgets/draggable
  jquery-ui/widgets/resizable
  jquery-ui/widgets/autocomplete
  jquery-ui/widgets/button
  jquery-ui/widgets/dialog
  jquery-ui/widgets/menu
  jquery.validate
  waypoints/noframework.waypoints
  jquery-unique-clone
).each do |asset|
  require_asset asset
end

# Plugin Library Dependencies
append_javascripts('storefront.dependencies')
```

This code creates an array of asset paths and then loops over the array, passing each path to `require_asset`, which is explained above.

Each asset in the array is a 3rd party library or framework on which Workarea JavaScripts depend. None of these files are bundled with Workarea. Instead, each file is included through a Ruby gem. Those gems are `require`d by workarea-core, which makes the assets available to the asset pipeline.

Following the `require_asset` loop is call `append_javascripts`. This is the same method covered in the head manifest section above, but the name of this append point is 'storefront.dependencies'. As the name of the method suggests, append points allow [plugins to append their JavaScripts to a manifest](/articles/appending.html).

### JavaScript Templates

The next section is structured like the section above it, but the referenced assets are [JavaScript templates](/articles/javascript-templates.html). In the Storefront example below, some of the assets are from workarea-core, while the others are from workarea-storefront. The Admin application manifest similarly contains a mixture or Core and Admin templates. Templates in workarea-core are shared between the Admin and Storefront.

```ruby
# JST Templates
%w(
  workarea/core/templates/ui_menu_heading
  workarea/core/templates/ui_menu_item
  workarea/core/templates/lorem_ipsum_view
  workarea/core/templates/reveal_password_button
  workarea/storefront/templates/loading
  workarea/storefront/templates/message
  workarea/storefront/templates/message_dismiss_action
  workarea/storefront/templates/button
  workarea/storefront/templates/same_as_shipping_button_property
  workarea/storefront/templates/saved_addresses_property
  workarea/storefront/templates/log_out_link
  workarea/storefront/templates/page_header_cart_count
  workarea/storefront/templates/pagination_button
).each do |asset|
  require_asset asset
end

# Plugin JST Templates
append_javascripts('storefront.templates')
```

Following the `require_asset` loop is another call to `append_javascripts`, this time allowing Plugins to append their templates to the manifest.

### jQuery UI Widgets

Workarea uses a variety of [jQuery UI](https://jqueryui.com/) widgets, such as dialog and autocomplete, to build out the Storefront and Admin user interfaces. Workarea also extends jQuery UI, using the provided [widget factory](https://jqueryui.com/widget/), to create custom widgets.

Those widgets are included in the manifest next. Although previous versions of Workarea had more, there is now only one. Poor little fella.

```ruby
# Library Extensions
%w(
  jquery_ui/core/categorized_autocomplete
).each do |asset|
  require_asset asset
end
```

Note that these files (ok, file) are in a subdirectory of `jquery_ui` rather than `workarea` since they follow the rules established by the jQuery framework, not Workarea.

### workarea.js

Next up is the workarea.js file.

```ruby
# Workarea Module Controller
require_asset 'workarea/core/workarea'
```

This file establishes the `WORKAREA` namespace, the global variable on which the Workarea JavaScript API is built. Everythig before this point in the manifest hangs off other globals, like `$`, `_`, and `JST`, for example. workarea.js will not overwrite an existing `WORKAREA` global if for some reason you need to define it earlier in your app.

After establishing the top level namespace, the methods `registerModule` and `initModules` are added to it. If you didn't already guess, these are used to register and init [Workarea JavaScript modules](/articles/javascript-modules.html).

### Configuration Files

[Configuration files](/articles/configuration.html) are included next in the application manifest, including an append point for plugins. This is where the global `WORKAREA.config` object is defined and subsequently added to.

```ruby
# Configuration
%w(
  workarea/core/config
  workarea/storefront/config
).each do |asset|
  require_asset asset
end

# Plugin Configuration
append_javascripts('storefront.config')
```

### Routes

Included next are files that allow [accessing routes in javascript](/articles/access-routes-in-javascript.html).

```ruby
# Routing
%w(
  workarea/core/routes
  workarea/storefront/routes
).each do |asset|
  require_asset asset
end
```

### Modules

Everything up until this point has been an opening act—fun, but not what you came out for. **[Modules](/articles/javascript-modules.html) are the band you came to see**, and they get added to the manifest next. Modules make use of the dependencies, templates, jQuery UI widgets, namespaces, configs, and routes above to do the actual client-side work.

```ruby
# Modules
%w(
  workarea/core/modules/transition_events
  workarea/core/modules/environment
  workarea/core/modules/cookie
  workarea/core/modules/string
  workarea/core/modules/url
  workarea/core/modules/image
  workarea/core/modules/deletion_forms
  workarea/core/modules/form_submitting_controls
  workarea/core/modules/jquery
  workarea/core/modules/style_guide_empty_links
  workarea/core/modules/style_guide_autocomplete_fields
  workarea/core/modules/reveal_password
  workarea/core/modules/local-time
  workarea/storefront/modules/forms
  workarea/storefront/modules/dialog
  workarea/storefront/modules/dialog_buttons
  workarea/storefront/modules/dialog_forms
  workarea/storefront/modules/dialog_close_buttons
  workarea/storefront/modules/loading
  workarea/storefront/modules/messages
  workarea/storefront/modules/pagination
  workarea/storefront/modules/current_user
  workarea/storefront/modules/break_points
  workarea/storefront/modules/primary_nav_content
  workarea/storefront/modules/product_details_sku_selects
  workarea/storefront/modules/popup_buttons
  workarea/storefront/modules/search_fields
  workarea/storefront/modules/alternate_image_buttons
  workarea/storefront/modules/scroll_to_buttons
  workarea/storefront/modules/address_region_fields
  workarea/storefront/modules/checkout_addresses_forms
  workarea/storefront/modules/checkout_shipping_services
  workarea/storefront/modules/checkout_primary_payments
  workarea/storefront/modules/single_submit_forms
  workarea/storefront/modules/log_out_link_placeholders
  workarea/storefront/modules/admin_toolbar
  workarea/storefront/modules/analytics
  workarea/storefront/modules/cart_count
  workarea/storefront/modules/recommendations_placeholders
  workarea/storefront/modules/recent_views
  workarea/storefront/modules/workarea_analytics
  workarea/storefront/modules/mobile_nav_button
).each do |asset|
  require_asset asset
end

# Plugin Modules
append_javascripts('storefront.modules')
```

Similarly to the other manifest sections, modules are loaded from both Core and Storefront (or Admin if looking at the Admin application manifest), and plugins can append their modules after the Core and Storefront modules.

### Module Initialization

The last line of the manifest is executable JavaScript code used to initialize modules. This process is covered in detail in the [JavaScript Modules](/articles/javascript-modules.html) guide.

```js
WORKAREA.initModules($(document));
```

## Admin's Application Manifest

The Admin has one single application manifest, but it is loaded at the end of the `head` element rather than the `body`. This is because the Admin uses a library called [Turbolinks](https://github.com/turbolinks/turbolinks) which aims to make navigating the Admin faster. This is achieved by loading the entire `document` once and relying on AJAX-enabled links to replace the `body` tag with that of the next page each time a request is made.

Since there is only one manifest, and since it is appended to the `head`, it is naturally an amalgam of both a head and application manifest, as outlined int he previous sections.

Because the Admin uses Turbolinks, we handle the last part of the Admin's application manifest a little differently:

### Module Initialization

```js
$(document).on('turbolinks:load', function () {
    WORKAREA.initModules($(body)); // Initialize all modules
});
```

Turbolinks provides [event hooks](https://github.com/turbolinks/turbolinks#full-list-of-events) for each stage of the request and response functionality it handles. When a page is requested and its `body` tag replaces the current `body` tag, it fires a `turbolinks:load` event. This is the hook we use to initialize our modules.

### Handling Outbound Linking

```js
$(document).on('turbolinks:click', function (event) {
  var goingElsewhere = !_.includes(
      event.originalEvent.data.url,
      WORKAREA.routes.admin.rootPath()
  );

  if (goingElsewhere) {
    event.preventDefault();
  }
});
```

Since Turbolinks has controls clicks on all links in its domain, we listen for and stop this behavior for links that do not begin with `http://domain.com/admin`.

### Handling Outbound Redirects

```js
$(document).on('turbolinks:request-end', function(event) {
  var redirectElsewhere = !_.includes(
      event.originalEvent.data.xhr.responseURL,
      WORKAREA.routes.admin.rootPath()
  );

  if (redirectElsewhere) {
      event.preventDefault();
      window.location = event.originalEvent.data.url;
  }
});
```

Similarly, when we detect that an asynchronous request should redirect to an outbound URL, we hijack that interaction as well.

## Adding and Removing JavaScripts

Oh yeah, I guess this guide was supposed to be about adding and removing JavaScripts through a manifest. Well, now that you know how the manifests are structured, adding and removing files is as easy as adding and removing paths within the various arrays.

If the asset you want to include has been packaged as a gem, first add the gem to your Gemfile and then require the asset in your manifest using the path to the asset within the gem. If the asset is not available as a gem, simply download the asset and copy it to your application's `vendor/assets/javascripts` directory and reference it from there.

```ruby
%w(
  # ...
  your_additional_asset # from some_gem/app/assets/javascripts
  your_additional_additional_asset # from your_app/vendor/assets/javascripts
).each do |asset|
  require_asset asset
end
```

Refer to [Appending](/articles/appending.html) for advice on managing plugin JavaScripts in your manifests.
