---
title: Progressive Web Application (PWA) Support 
created_at: 2018/11/09
excerpt: Learn how to modify and extend the out-of-the-box solution for asset precaching provided by the platform
---

# Progressive Web Application Support

The Workarea Commerce Platform ships with the foundational implementation of a [Progressive Web Application](https://developer.mozilla.org/en-US/docs/Web/Apps/Progressive) (PWA) which prompts a user to install the application directly to their smartphone home screen. This functionality is provided by [Service Workers](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API). 

The following sections cover an overview of the files involved and some more information about various caching techniques you can employ to custom fit the PWA to your client's specific needs.

## Overview

Support for Service Workers in the platform is provided by the [serviceworker-rails gem](https://github.com/rossta/serviceworker-rails). The main benefit this gem provides is its middleware, which allows us to serve each Service Worker from the website's root context and more granularly control response headers. It should be noted that the gem also provides a generator which is disabled by the platform, as its functionality is not useful to the host application. Overriding of each file can be done using the [workarea:override generator](/articles/overriding.html).

### Configuration

Out of the box the platform configures the `serviceworker-rails` gem to provide a route to the main `pwa_cache.js` Service Worker, then adds that routed file for precompilation:

```rb
# core/config/initializers/21_serviceworkers.rb

...

# Configure serviceworker-rails
app.config.serviceworker.routes.draw do
  match '/pwa_cache.js' => 'workarea/storefront/serviceworkers/pwa_precache.js'
end

# Precompile the required assets
app.config.assets.precompile += %w(pwa_cache.js)
```

Each Service Worker written for the website will need to be handled similarly. You can [adjust this configuration in an initializer](/articles/configuration.html) within the host application.

### Registering a Service Worker

Though Service Workers are not served from within the [JavaScript manifest](/articles/add-javascript-through-a-manifest.html) they are registered through files that are. These [registration scripts](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API/Using_Service_Workers#Registering_your_worker) live at the top of the manifest in the following section:

```rb
# Service Worker Registrations
%w(
  workarea/storefront/serviceworkers/register_pwa_cache
).each do |asset|
  require_asset asset
end

# Plugin Service Worker Registrations
append_javascripts('storefront.serviceworker_registrations')

...
```

The contents of the `register_pwa_cache.js` file will use the configured route during registration:

```js
// app/assets/javascripts/workarea/storefront/serviceworkers/register_pwa_cache.js

'use strict';

if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/pwa_cache.js', { scope: './' });
}
```

### Asset Pre-Caching

The [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) provides the lifecycle for the `pwa_cache.js` script, which is only responsible for the initial precaching of assets (after installing the PWA) and the display of an offline error page (when a network request is made) if the device disconnects from the network during a request. The offline error page messaging is provided by System Content and is administrable within the Admin.

```js
// app/assets/javascripts/workarea/storefront/serviceworkers/pwa_cache.js

'use strict';

/**
 * On PWA installation, pre-cache the assets & offline page
 */
self.addEventListener('install', function (event) {
    event.waitUntil(
        caches.open('pwa_cache').then(function (cache) {
          return cache.addAll([
            '<%= image_path("workarea/storefront/logo.png") %>',
            '<%= stylesheet_path("workarea/storefront/application.css") %>',
            '<%= javascript_path("workarea/storefront/head.js") %>',
            '<%= javascript_path("workarea/storefront/application.js") %>',
            '/offline'
          ]);
        })
    );
});

/**
 * On PWA fetch, serve the offline system content page if the connection fails
 */
self.addEventListener('fetch', function (event) {
    if (event.request.mode !== 'navigate') { return; }
    if (event.request.method !== 'GET') { return; }
    if ( ! event.request.headers.get('accept').includes('text/html')) { return; }

    event.respondWith(
        fetch(event.request).catch(function () {
            return caches.match('/offline');
        })
    );
});
```

During the `install` event, the cache is filled with a list of assets and an offline error page that will be displayed if and when the device loses connectivity while browsing. During the `fetch` event, we test the request to make sure it's a valid page request, and display said offline error page as needed.

You may be concerned about serving stale files from the cache at this point. Service Workers that have been installed to the device are regularly checked against the version hosted on the server. If they differ, they are reinstalled in the background. For each cached file whose path is provided by one of Rails' Asset Helpers (`image_path, `stylesheet_path`, etc) Sprockets will append a fingerprint to the filename, which will trigger the Service Worker to reinstall and update the cache automatically within a 24 hour window. This will also trigger an update for the offline error page if any changes have been made.

## Adding Assets to the Cache

All types of assets can be added to the cache. We have chosen to add the site's logo, the Stylesheet and JavaScript manifests, and the offline error page as a sensible foundation. Caching font files, icons and other images in addition to what's already provided may be in your best interest.

If you need to add files to the cache, [override](/articles/overriding.html) the `pwa_cache.js` file and add any assets you'd like to store on the device in advance.

Adding a font might look something like this:

```js
...

return cache.addAll([

  '<%= font_path("workarea/storefront/roboto.woff") %>',
  '<%= font_path("workarea/storefront/roboto.woff2") %>',

  '<%= image_path("workarea/storefront/logo.png") %>',
  '<%= stylesheet_path("workarea/storefront/application.css") %>',
  '<%= javascript_path("workarea/storefront/head.js") %>',
  '<%= javascript_path("workarea/storefront/application.js") %>',
  '/offline'
]);

...
```

## Employing Additional Caching Techniques

The platform takes a rather hands-off approach to prescribing what will be cached by the PWA. As you can see from the examples above no pages are even being cached by default. This is an intentional choice made to allow more flexibility in the host application.

There are many caching techniques out there, but here are some resources to help you achive a caching plan that's right for your application:

* [Google Developer's Offline Cookbook](https://developers.google.com/web/fundamentals/instant-and-offline/offline-cookbook/)
* [Google Developer's Service Worker Lifecycle](https://developers.google.com/web/fundamentals/primers/service-workers/lifecycle)
* [Google Workbox](https://developers.google.com/web/tools/workbox/)
* [Progressive Web Applications on MDN](https://developer.mozilla.org/en-US/docs/Web/Apps/Progressive)
* [Service Workers Cookbook](https://serviceworke.rs/)
