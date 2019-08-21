---
title: Configure ImageOptim
created_at: 2018/09/17
excerpt: Workarea uses the image_optim gem to optimize images. It will grab the global Rails image_optim config when looking for configuration.
---

# Configure ImageOptim

Workarea uses the image\_optim gem to optimize images. It will grab the global Rails image\_optim config when looking for configuration.

your\_app/config/initializers/image\_optim.rb:

```
My::Application.configure do
  # These are the default values
  config.assets.image_optim = {
    pack: true,
    pngout: false,
    svgo: false
  }
end
```


