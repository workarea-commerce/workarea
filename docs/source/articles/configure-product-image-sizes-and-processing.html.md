---
title: Configure Product Image Sizes & Processing
created_at: 2018/07/31
excerpt: There is an initializer which sets up a Dragonfly application for the Workarea platform. This initializer sets up image optimization, URLs, logging, etc.
---

# Configure Product Image Sizes & Processing

There is an initializer which sets up a Dragonfly application for the Workarea platform. This initializer sets up image optimization, URLs, logging, etc.

This configuration can be reopened in the host app to override settings, processing, or add additional image sizes. Full documentation is available at [the official Dragonfly configuration documentation.](http://markevans.github.io/dragonfly/configuration).

your\_app/config/initializers/dragonfly.rb:

```
Dragonfly.app(:workarea).configure do
  # Add a new image size
  processor :micro_thumb do |content|
    content.process!(:encode, :jpg, '-quality 100')
    content.process!(:thumb, '50x50#')
    content.process!(:optim)
  end

  # Change admin upload asset URLs
  url_format '/media/:job/:name'
end
```


