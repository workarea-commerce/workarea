---
title: Favicon Support
created_at: 2018/12/03
excerpt: Learn how Workarea manages favicons and how they are output in your application
---

# Favicon Support

Favicons are a collection of images used by browsers and mobile devices to visually represent a site within their user interfaces. Due to the variation between browsers and mobile devices, favicons are typically supplied in a variety of sizes and via a number of delivery methods.

Suffice it to say that long passed are the days of simply dropping a `favicon.ico` file in your site's root directory.

The good news is that Workarea provides a way to set and automate the creation and linking of these assets without developer intervention through the Admin.

## Setting an asset as a favicon

Within the Admin, a user may use an Asset's <em>tags</em> field to denote that the Asset should be used as a favicon.

<!-- TODO v3.4 mention the visual indicator -->

For a single Asset to be used as the site's favicon the Admin user may simply add the `favicon` tag to the chosen Asset. Once this is done, the platform will create, output, and link all necessary files automatically.

For more granular control over each generated favicon, an Admin user may apply tags to the chosen Asset in the following format: `favicon-SIZE`. For example, if the chosen Asset does not scale well and is visually unintelligible when scaled down to 16 pixels (the smallest required favicon size), the user may choose another, smaller Asset to replace this size by applying the `favicon-16x16` tag to the Asset.

The majority of the generated favicons will be of type `.png`, though a fallback `favicon.ico` file is still generated for canonical posterity and for use with older browsers. To manually override this icon, a user may simply denote an Asset as the `.ico` fallback by applying the `favicon-ico` tag to the Asset. Since tagging supports multiple, comma-delimited values, an Asset can carry more than one favicon tag at a time.

<!-- TODO v3.4 mention the favicon placeholder fallback -->

It should be noted that favicons are intended to be square images.

## Favicon asset and manifest automation

The markup necessary for rendering the generated favicons is added to each Storefront layout via methods found within `Workarea::Storefront::FaviconsHelper`. This helper renders the `workarea/storefront/favicons/tags` partial, where the following is generated:

<!-- TODO v3.4 remove web manifest? -->

* A link to a 180x180 pixel Apple Touch icon
* A link to a 32x32 pixel .png icon
* A link to a 16x16 pixel .ico icon
* A link to a web manifest file 
* A meta tag providing the URL to a browserconfig file 
* A meta tag to specify the tile color for use in the Microsoft Windows Metro UI
* A meta tag to specify the color of the browser's "theme", a feature available on some devices

The color-specific settings are output as the aforementioned meta tags in addition to appearing as entries within the web manifest and browserconfig files. These settings are configurable via:

```ruby
Workarea.config.web_manifest.tile_color
Workarea.config.web_manifest.theme_color
```

URLs for each linked icon are provided by the following `FaviconsHelper` methods:

* `Workarea::Storefront::FaviconsHelper#favicons_path` generates a URL to a dynamically sized `.png` file
* `Workarea::Storefront::FaviconsHelper#favicon_path` generates a URL to the `favicon.ico` file

Each favicon is dynamically generated on demand using Dragonfly. The following custom dragonfly processors defined within `core/config/initializers/07_dragonfly.rb`:

* `:favicon` handles the resizing of a file to the passed size.
* `:favicon_ico` handles the conversion to the `.ico` format.

<!-- TODO v3.4 remove below --> 
Lastly, if there is no Asset tagged as a favicon, the system will not generate any of the above. 

## Favicon URLs

Storefront routes are provided to handle requests for an icon of a particular size and the `favicon.ico` file itself. These routes are:

* `dynamic_favicon` which takes no parameters, returning the `favicon.ico` and serving the file from `https://domain.com/favicon.ico`
* `dynamic_favicons` which takes a size parameter, returns a `.png` version and serving the file from, for example, `https://domain.com/favicons/32x32.png` if the requested size parameter is set to `32x32`.

Both of these routes are Dragonfly endpoints which handle the favicon rendering within `Workarea::AssetEndpoints::Favicons`. This class has two methods to match the provided routes:

* `result` handles the dynamic_favicons request, restricting sizes to those defined within `Workarea.config.favicon_allowed_sizes`, preventing DDOS attacks that may try to request many varying sizes at once.
* `ico` handles the generation of the `favicon.ico` file by finding the appropriate Asset and running it through the `:favicon_ico` Dragonfly processor.

## The Web Manifest
 
<!-- TODO v3.4 explain repurposing for PWA apps -->

The rendered favicon tags in the layout link each page to a web manifest.

A web manifest is a file that can inform devices how to style particular elements of the client UI when accessing the site. In addition to favicon settings, it provides further configuration for theme coloring and other basic meta information for the site. Further information can be found on the following sites:

* [https://developer.mozilla.org/en-US/docs/Web/Manifest](https://developer.mozilla.org/en-US/docs/Web/Manifest)
* [https://developers.google.com/web/fundamentals/web-app-manifest/](https://developers.google.com/web/fundamentals/web-app-manifest/)

The Workarea platform automatically generates this file from `Storefront::PagesController#web_manifest` via a route which serves the file from `https://domain.com/site.webmanifest`. The file itself is in JSON format and lives at `storefront/pages/web_manifest.json.jbuilder` in the views directory and will be cached by Rack cache.

This template contains a mix of favicon images and configuration values to provide a basic web manifest which can be expanded upon to suit your client's needs. Out of the box it provides:

* **name** using `Workarea.config.site_name`
* **short_name** also using `Workarea.config.site_name`
* **icons** containing
  * a 192x192 `.png` icon
  * a 512x512 `.png` icon
* **theme_color** using `Workarea.config.web_manifest.theme_color`
* **background_color** using `Workarea.config.web_manifest.background_color`
* **start_url** using `'/?utm_source=homescreen'`
* **display** using `Workarea.config.web_manifest.display_mode`

## Browserconfig
 
The rendered favicon tags in the layout also link each page to a browserconfig file.

A browserconfig file informs Microsoft Windows devices on how they should present and style their UI elements when accessing the site. This file is similar to the web manifest in many regards. The main difference is that this file is in XML format.

Like the web manifest, the Workarea platform automatically generates this file from `Storefront::PagesController#browser_config` via a route which serves the file from `https://domain.com/browserconfig.xml`. The file itself is in XML format and lives at `storefront/pages/browser_config.xml.builder` in the views directory and will be cached by Rack cache.

Also like the web manifest, this template contains a mix of favicon iamges and configuration values which can further be expanded upon to suit your client's needs. By default it offers:

* **square150x150logo** which is dynamically generated 
* **TileColor** defined by `Workarea.config.web_manifest.tile_color`, for use in the Windows Metro UI
