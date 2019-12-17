---
title: Add JavaScript through a View
created_at: 2018/07/31
excerpt: 'Note: First of all, are you sure?! Assets added to views are not optimized in any way for production environments like assets added through manifests. Peppering your views with JavaScript also makes your application more difficult to debug and maintai'
---

# Add JavaScript through a View

**Note:**  **First of all, are you sure?!** Assets added to views are not optimized in any way for production environments like [assets added through manifests](/articles/add-javascript-through-a-manifest.html). Peppering your views with JavaScript also makes your application more difficult to debug and maintain. However, there are legitimate reasons to add JavaScripts in this way, so read on!

## JavaScript Haml Filter

To include JavaScript directly in a Haml view, use the nifty `:javascript` filter. Haml sees the contents as JavaScript and wraps them in a `script` tag when rendered as HTML.

```
:javascript
  alert('foo');
```

The script tag will be output exactly where you put it in the view.

Libraries like jQuery, which are included at the bottom of the layout in the application manifest, aren't defined yet. Your inline script can't use them, which may be undesirable. To output the script tag below the application manifest, use `content_for(:javascript)`.

## content\_for(:javascript)

By wrapping your JavaScript in content\_for(:javascript), it will be output wherever `yield :javascript` appears in the layout. By default, this is output directly after the application.js manifest in each Workarea layout. Note that the `:javascript` identifier in this case is just a way of matching up `content_for` with `yield`, as described in the [Layouts & Rendering Rails guide](http://guides.rubyonrails.org/layouts_and_rendering.html). The example below combines `content_for(:javascript)` with the `:javascript` Haml filter.

```
- content_for :javascript do
  :javascript
    alert('foo');
```

No matter where you include that in the view, the rendered `script` element will be output at the bottom of the page, underneath the application manifest, providing access to all the scripts it contains.

## add\_javascript Helper

The `add_javascript` view helper, a Workarea feature, is esentially a shorthand for the above example. It takes a string of JavaScript code as its only argument. It calls `.html_safe` on the string to escape it, and wraps the string with an HTML script tag before outputting it into the layout at the location of `yield :javascript`. Therefore, the following code examples provide the same result.

```
- content_for :javascript do
  :javascript
    alert('foo');
```

```
- add_javascript "alert('foo');"
```

This helper is used primarily for internal use, as a macro at the top of several views to declaratively [include JavaScript entered through the Admin UI](/articles/add-javascript-through-the-admin-ui.html).

For example, this appears near the top of the home page view, to add to the page any JavaScript entered through the Admin that's stored in MongoDB.

```
- add_javascript(@page.javascript)
```

## Partials from Plugins

The last technique I'll mention is `append_partials`, which each Workarea layout calls twice—once in the head and once in the body.

workarea-storefront/app/views/layouts/workarea/storefront/application.html.haml:

```
%head
  /...
  / directly before the head manifest
  = append_partials('storefront.document_head')
  /...
%body
  /...
  / directly after the application manifest and yield :javascript
  = append_partials('storefront.javascript')
  /...
```

These append points allow [plugins to append their partials](/articles/appending.html) to the layout. The partials may contain JavaScript using any of the techniques above.

The Google Analytics plugin, for example, uses the head append point to insert a view which includes nothing but the Google Analytics embed code.


