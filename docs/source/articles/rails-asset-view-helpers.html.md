---
title: Rails Asset View Helpers
created_at: 2018/07/31
excerpt: Each Rails view that ships with Workarea uses view helpers provided by Rails to link to assets and construct asset tags, such as script tags that include JavaScript on the page.
---

# Rails Asset View Helpers

Each Rails view that ships with Workarea uses view helpers provided by Rails to [link to assets](http://api.rubyonrails.org/classes/ActionView/Helpers/AssetUrlHelper.html) and [construct asset tags](http://api.rubyonrails.org/classes/ActionView/Helpers/AssetTagHelper.html), such as `script` tags that include JavaScript on the page.

The head and application script tags mentioned in [the JavaScript overview](/articles/javascript-overview.html) are constructed in each Workarea layout by calling `javascript_include_tag`. Out of the box, the method is called twice in each layout, once in the document head and once in the body, as shown in the example below.

workarea-storefront/app/views/layouts/workarea/storefront/application.html.haml:

```
%head
  /...
  = javascript_include_tag 'workarea/storefront/head'
  /...
%body
  /...
  = javascript_include_tag 'workarea/storefront/application'
  /...
```


