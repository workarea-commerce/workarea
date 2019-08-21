---
title: HTTP Caching
excerpt: All major content, browse, and search pages are cached for a short and configurable duration by an HTTP cache. This allows the system to serve a large number of requests in a short period of time.
---

# HTTP Caching

All major content, browse, and search pages are cached for a short and configurable duration by an HTTP cache. This allows the system to serve a large number of requests in a short period of time.

storefront/app/controllers/workarea/storefront/pages\_controller.rb:

```
module Workarea
  class Storefront::PagesController < Storefront::ApplicationController
    before_filter :cache_page
    # ...
  end
end
```

Controller/actions which enable this include:

- `Workarea::Storefront::CategoriesController#show`
- `Workarea::Storefront::PagesController#show`
- `Workarea::Storefront::PagesController#home_page`
- `Workarea::Storefront::ProductsController#show`
- `Workarea::Storefront::SearchesController#show`

This creates a major complication for any data on the page with user or session specific. Examples include login status, cart count, and personalized product recommendations. Workarea solves this problem by loading this content asynchronously via Javascript. Make sure you review any customized functionality to ensure you won't be caching pages with session-specific data.

**Note:** [Rack::Cache](http://rtomayko.github.io/rack-cache/) is a simple way to achieve the caching advantage explained above without the configuration and hosting burden of a more robust HTTP cache like [Varnish](https://www.varnish-cache.org).

## Customizing the Rack::Cache Key

There are scenarios where it becomes necessary to vary `Rack::Cache` entries, like geolocated content blocks or segmentation-based navigation. In these cases, Workarea provides a relatively straight-forward way to add to the cache key. Refer to [the documentation in the code for Workarea::Cache::Varies](https://github.com/workarea-commerce/workarea/blob/master/core/lib/workarea/cache.rb) for more information.

**Note:** Using `Workarea::Cache::Varies` can have a _very_ adverse affect on application performance, and is not encouraged. Make sure this is what you need, and feel free to reach out on [Slack](https://workarea-community.slack.com) to see if there may be a better way to achieve your goals.

## Resources on HTTP Caching

- [W3 Spec](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html)
- [Web Fundamentals: HTTP caching](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching?hl=en)
- [HTTP Caching in Ruby with Rails](https://devcenter.heroku.com/articles/http-caching-ruby-rails)
