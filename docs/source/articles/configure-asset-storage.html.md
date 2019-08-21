---
title: Configure Asset Storage
created_at: 2018/07/31
excerpt: Asset storage configuration determines where product images, content images, admin uploads, etc are stored.
---

# Configure Asset Storage

Asset storage configuration determines where product images, content images, admin uploads, etc are stored.

The configuration created here is passed through to the Dragonfly app. Full documentation on Dragonfly storage can be found at [the official Dragonfly documentation](http://markevans.github.io/dragonfly/data-stores)

your\_app/config/initializers/workarea.rb:

```
Workarea.configure do |config|
  # Store assets on the local filesystem (default)
  config.asset_store = :file_system, {
    root_path: '/tmp/workarea',
    server_root: '/tmp/workarea'
  }

  # Store assets on S3
  # config.asset_store = :s3, {
  # bucket_name: 'XXXX',
  # access_key_id: 'XXXX',
  # secret_access_key: 'XXXX'
  # }
end
```
