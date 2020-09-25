---
title: HTTP Caching
created_at: 2019/03/14
excerpt: All major content, browse, and search pages are cached for a short and configurable duration by an HTTP cache. This allows the system to serve a large number of requests in a short span of time.
---

# HTTP Caching

All major content, product, browse, and search pages are cached for a short and configurable duration by an HTTP cache. This allows the system to serve a large number of requests in a short span of time. This is implemented by the `:cache_page` method run in a [before_action](https://guides.rubyonrails.org/action_controller_overview.html#filters) filter:

```ruby
# storefront/app/controllers/workarea/storefront/pages_controller.rb
module Workarea
  class Storefront::PagesController < Storefront::ApplicationController
    before_action :cache_page
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

## Using Rack::Cache

Workarea applications use [Rack::Cache](https://github.com/rtomayko/rack-cache) to store their HTTP cache. `Rack::Cache` is a HTTP caching Rack middleware. It's backed by [Redis](https://github.com/redis-store/redis-rack-cache), in which `Rack::Cache` stores all of its metadata and actual cached content.

Out of the box, the effects of `Rack::Cache` are disabled in `test` and `development` environments.

### Ignore User-Specific Tracking Parameters in the Query String

Many stores on the Workarea platform use marketing tools such as [Listrak](https://github.com/workarea-commerce/workarea-listrak) or [Emarsys](https://github.com/workarea-commerce/workarea-emarsys) to handle abandoned cart emails, marketing campaigns, and so on. These services sometimes use query parameters within the URL to identify each individual user, and this can cause an issue with caching. `Rack::Cache` will, by default, generate cache keys based on the given URL. So, if you have multiple requests to your **/categories/shirts** page, like this:

```
GET /categories/shirts?tracking_id=96a30500-6add-47e1-9ee8-cf3b5052ecf3
GET /categories/shirts?tracking_id=9d9948e3-df0b-4b17-9396-4bbcbac7f4c9
GET /categories/shirts?tracking_id=0ffc0e09-4041-4876-8f8e-05ae87bc3bf3
```

That will result in multiple entries written to the cache for the same exact request. This is inefficient at best, and dangerous to your performance at worst. To make sure you won't run into this situation, `Rack::Cache` [allows you to configure ignored query parameters](https://github.com/rtomayko/rack-cache#ignoring-tracking-parameters-in-cache-keys), and since Workarea uses its own subclass of `Rack::Cache::Key`, you'll need to customize the tracking params on that class like so:

```ruby
Workarea::Cache::RackCacheKey.query_string_ignore = proc { |key, value| key == 'tracking_id' }
```

If you're using the `Workarea::Listrak` plugin, you're in luck! 🍀 Recent versions of the plugin [include configuration for the cache key](https://github.com/workarea-commerce/workarea-listrak/blob/master/config/initializers/rack_cache.rb) out of the box, so you won't need to do anything to get efficient caches in production.

### Customizing the Cache Key

There are scenarios where it becomes necessary to vary `Rack::Cache` entries, like geolocated content blocks or segmentation-based navigation. In these cases, Workarea provides a relatively straight-forward way to add to the cache key. Refer to [the documentation in the code for Workarea::Cache::Varies](https://github.com/workarea-commerce/workarea/blob/master/core/lib/workarea/cache.rb) for more information.

**Note:** Using `Workarea::Cache::Varies` can have a _very_ adverse affect on application performance, and is not encouraged. Make sure this is what you need, and feel free to reach out on [Slack](https://workarea-community.slack.com) to see if there may be a better way to achieve your goals.

## Resources on HTTP Caching

- [W3 Spec](http://www.w3.org/Protocols/rfc2616/rfc2616-sec13.html)
- [Web Fundamentals: HTTP caching](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching?hl=en)
- [HTTP Caching in Ruby with Rails](https://devcenter.heroku.com/articles/http-caching-ruby-rails)
