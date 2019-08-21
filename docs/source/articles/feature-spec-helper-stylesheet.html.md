---
title: Feature Test Helper Stylesheet
created_at: 2018/07/31
excerpt: 'In a test environment, the application stylesheet manifest includes the following style rules:'
---

# Feature Test Helper Stylesheet

In a test environment, the application stylesheet manifest includes the following style rules:

```
/**
 * "Disable" transitions and animations in the test environment
 */

* {
    transition: none !important;
    animation: none !important;
}
```

These rules effectively disable CSS transitions and animations in the test environment.

Workarea applies these styles to allow for more reliable full stack automated tests. If you are not running any of Workarea's tests, you may remove this code if you prefer.


