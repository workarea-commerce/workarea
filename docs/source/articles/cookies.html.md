---
title: Cookies
created_at: 2020/09/04
excerpt: An overview of the cookies used by Workarea.
---

# Cookies Overview

This page provides an overview of the cookies used by Workarea out-of-the-box for various functionality. Not all visitors may have all these cookies, depending on the functionality.

| Name | Expiration | Signed | Notes |
|---|---|---|---|
| `_#{app_name}_session` | 30 minutes | `true` | Stores login information for the user. Reset on logout. |
| `order_id` | 20 years | `true` | Tracks the current cart for checkout. |
| `workarea_referrer` | 7 days | `false` | Stores the first known referrer, used for segmentation and analytics. |
| `email` | 20 years | `true` | The current email (if known), used for metrics and segmentation. |
| `analytics_session` | 30 minutes | `false` | Used to mark whether there's a currently active session |
| `sessions` | 20 years | `false` | The number of sessions, based on `analytics_session`. Used for segmentation. |
