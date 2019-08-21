---
title: Configure Low Inventory Threshold
created_at: 2018/07/31
excerpt: config.low_inventory_threshold determines the minimum available quantity for a sku before low inventory status is displayed. Configure the value in an initializer.
---

# Configure Low Inventory Threshold

`config.low_inventory_threshold` determines the minimum available quantity for a sku before low inventory status is displayed. Configure the value in an initializer.

your\_app/config/initializers/workarea.rb:

```
# ...

Workarea.configure do |config|

  # ...

  config.low_inventory_threshold = 5

  # ...

end
```


