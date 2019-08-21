---
title: Low-Level Caching
created_at: 2018/07/31
excerpt: Certain slow or frequently running queries or processing are cached from the classes defining them. The Workarea system follows the Rails convention in how this is handled.
---

# Low-Level Caching

Certain slow or frequently running queries or processing are cached from the classes defining them. The Workarea system follows the Rails convention in how this is handled.

core/app/models/workarea/shipping/service.rb:

```
def self.cache
  Rails.cache.fetch('shipping_services_cache', expires_in: Workarea.config.cache_expirations.shipping_services) do
    Shipping::Service.all.to_a
  end
end
```

The work to be cached is placed inside a call to the `Rails.cache`. Like the fragment caching in the views, if the cache store does not have a fresh cache, the block is executed and the result is cached.

## Resources on Low-Level Caching

- [Rails Guide: Low-Level Caching](http://guides.rubyonrails.org/caching_with_rails.html#low-level-caching)
- [Heroku: Low-Level Caching](https://devcenter.heroku.com/articles/caching-strategies#low-level-caching)
