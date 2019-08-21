---
title: Configure Asset Types
created_at: 2018/07/31
excerpt: You can configure the different types of available Content::Assets.
---

# Configure Asset Types

You can configure the different types of available `Content::Assets`.

your\_app/config/initializers/workarea.rb:

```
Workarea.configure do |config|
  config.asset_types = %w(image pdf flash video audio text)
end
```


