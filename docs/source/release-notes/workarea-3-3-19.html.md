---
title: Workarea 3.3.19
excerpt: Patch release notes for Workarea 3.3.19.
---

# Workarea 3.3.19

Patch release notes for Workarea 3.3.19.

## Update Products in Category After Rules Are Changed

Administrators had noticed in the past that the categories listing in
the product does not always seem up-to-date with what is true on the
storefront. This is because for categories where no product rules exist,
the `Workarea::IndexCategorization` job does not run. Workarea now
ensures that the category is removed before checking for product rules,
removing it on the product's "Categories" list in the admin, and
improving understandability for admin users. Additionally, a new
`IndexProductRule` is enqueued whenever product rules change, updating
categorization of products immediately when a rule is altered.

### Issues

- [ECOMMERCE-6573](https://jira.tools.weblinc.com/browse/ECOMMERCE-6573)

### Pull Requests

- [3797](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3797/overview)
- [3808](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3808/overview)

### Commits

- [87625fef0677dd76a6218687096507c0be1525c2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/87625fef0677dd76a6218687096507c0be1525c2)
- [d36a392c935c79583d132a3e505b76866e68577d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d36a392c935c79583d132a3e505b76866e68577d)
- [a511c9192968c6566ee21ab2fca4485e29651fe2](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a511c9192968c6566ee21ab2fca4485e29651fe2)

## Delete `guest_browsing` Cookie When Guest Browsing Ceases

When an admin stops browsing as guest, Workarea previously did not clear
out the guest_browsing cookie, causing the UI to appear as though they
were still browsing as guest. This cookie is now deleted when admins
click the "Stop Guest Browsing" button in the toolbar (or elsewhere).

### Issues

- [ECOMMERCE-6611](https://jira.tools.weblinc.com/browse/ECOMMERCE-6611)

### Pull Requests

- [3787](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3787/overview)

### Commits

- [8f67a4c1f14015f21ad663468bec59f44f425794](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/8f67a4c1f14015f21ad663468bec59f44f425794)

## Auto-Configure `asset_host` Prior To App Configuration

In v3.3.x, the `Rails.configuration.asset_host` is configured
automatically before initialization. However, apps/plugins can still get
into a situation where this value is not automatically set, resulting in
unexpected behavior. To remedy this, Workarea now auto-configures the
asset host in Rails' `before_configuration` block, which runs directly
after the `Rails::Application` is inherited in **config/application.rb**,
in contrast to `before_initialize` which runs "near the beginning of the
Rails initialization process".

More Info: https://guides.rubyonrails.org/configuring.html#initialization-events


### Issues

- [ECOMMERCE-6631](https://jira.tools.weblinc.com/browse/ECOMMERCE-6631)

### Pull Requests

- [3796](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3796/overview)

### Commits

- [3389aadf38c718c27dc8dbca7bbbd9329ad37f15](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/3389aadf38c718c27dc8dbca7bbbd9329ad37f15)

## Look Up Tax Rate Using First 5 Digits of US Postal Codes if No Exact Matches Found

Some address verification systems will automatically include the last 4
digits of a given postal code in the US, which can be problematic if tax
tables do not include this information. When finding tax rates for a given
postal code in the US, search the DB for the first 5 digits of the postal
code in addition to the full passed-in value if there are no matches for the
latter, since most tax tables don't include the last 4 digit suffix of a ZIP
code.


### Issues

- [ECOMMERCE-6581](https://jira.tools.weblinc.com/browse/ECOMMERCE-6581)

### Pull Requests

- [3801](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3801/overview)
- [3771](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3771/overview)

### Commits

- [98a189f311afabf3b942db45f10a7d11eed69d39](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/98a189f311afabf3b942db45f10a7d11eed69d39)
- [f302bf6a8a91a36ac5ce006310862167993e6751](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f302bf6a8a91a36ac5ce006310862167993e6751)

