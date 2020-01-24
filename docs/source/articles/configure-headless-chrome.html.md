---
title: Configure Headless Chrome
created_at: 2020/01/23
excerpt: How to configure headless Chrome
---

# Configure Headless Chrome

Workarea system tests are run within a headless instance of Chrome, driven by Selenium.
Since Workarea 3.5.0, you can customize this setup using the following [configuration](/articles/configuration.html) values:

| Config | Description |
| --- | --- |
| [`headless_chrome_options`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/core/lib/workarea/configuration.rb#L953) | Options hash passed to the Selenium driver |
| [`headless_chrome_args`](https://github.com/workarea-commerce/workarea/blob/v3.5.3/core/lib/workarea/configuration.rb#L956-L962) | Array of command line arguments passed to the Chrome executable |

Replace or mutate the default values from within your [test helper](/articles/testing-concepts.html#test-helper):

```
# <your_application_root>/test/test_helper.rb 

Workarea.configure do |config|
  config.headless_chrome_options = {...}
  config.headless_chrome_args = [...]
end
```
