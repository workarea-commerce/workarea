---
title: Workarea 3.3.11
excerpt: Patch release notes for Workarea 3.3.11.
---

# Workarea 3.3.11

Patch release notes for Workarea 3.3.11.

## Prefer Most Specific Tax Rate When All Parameters Given

Providing a country and region to `Tax::Category.find_rate` when there
are rates that exist on the postal code level would previously return
those more specific postal code rates instead of the "general"
`Tax::Rate` for the state. Workarea now ensures that the `:postal_code`
on the rate is blank when a postal code is not given to the `.find_rate`
method.

### Issues

- [ECOMMERCE-6361](https://jira.tools.weblinc.com/browse/ECOMMERCE-6361)

### Pull Requests

- [3593](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3593/overview)

### Commits

- [fba171c48241816be36050c09efdbd395589d1cb](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/fba171c48241816be36050c09efdbd395589d1cb)
- [a8b9f27ffcb933902ffafc5ca2fdc80aebebfa3a](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/a8b9f27ffcb933902ffafc5ca2fdc80aebebfa3a)

## Track Contentable Area when Drafting Content

Workarea did not store the contentable area ID when content is saved as
a draft, causing problems downstream in content block plugins which need
to know about the contentable area in which they are located. This data
is now stored on the content block even when it is in draft form, giving
more context to the content block being edited.

### Issues

- [ECOMMERCE-6383](https://jira.tools.weblinc.com/browse/ECOMMERCE-6383)

### Pull Requests

- [3609](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3609/overview)

### Commits

- [85cd85d316569bfb4c0853a584ebd26a22263308](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/85cd85d316569bfb4c0853a584ebd26a22263308)

## Ensure Redirect Path is URI-Encoded Before Persisting

The `Navigation::Redirect#sanitize_path` callback could potentially
throw a `URI::InvalidURIError` if the given path is not valid. Workarea
now checks if the argument passed in is URI-encoded, according to the
specifications of [RFC 2396](https://www.ietf.org/rfc/rfc2396.txt). If it
has not already been encoded, `Navigation::Redirect.sanitize_path` will
call `URI.encode` to make sure that an error won't be thrown when
parsing as a URI.

### Issues

- [ECOMMERCE-6329](https://jira.tools.weblinc.com/browse/ECOMMERCE-6329)

### Pull Requests

- [3588](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3588/overview)

### Commits

- [2b7d7285f6105967c7fba4c3ea45918bdbf13b41](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/2b7d7285f6105967c7fba4c3ea45918bdbf13b41)
