---
title: API Overview
excerpt: Workarea provides 2 separate REST APIs, Admin and Storefront.
---

# API Overview

Workarea provides two separate REST APIs for different purposes:

* The [Admin API](https://github.com/workarea-commerce/workarea-api/tree/master/admin) provides CRUD
operations on all data models in the application and is primarily used for
integration with external service providers, such as an OMS or ERP. Access is
only available to admin users with the necessary "API Access" permissions.
* The [Storefront API](https://github.com/workarea-commerce/workarea-api/tree/master/storefront) is
suitable for building alternative user interfaces to Workarea. Some possible
uses for the Storefront API are: mobile apps, kiosks, or retail integrations.

Both of these APIs are contained in the
[workarea-api](https://github.com/workarea-commerce/workarea-api) plugin.

## API Documentation

Out of the box documentation for the Workarea APIs are available here:

* [Admin API](https://demo.workarea.com/api/docs/admin)
* [Storefront API](https://demo.workarea.com/api/docs/storefront)

When running the Workarea API in your application you should reference the
documentation generated for your application specifically. Generated API docs
include customizations to data models, as well as any endpoints available for
installed plugins. Generated docs are available at <https://your.staging.url.com/api/docs>.

For instructions on generating app specific API documentation, see the
Documentation section of the
[Workarea API Readme](https://github.com/workarea-commerce/workarea-api)
