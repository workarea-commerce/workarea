---
title: Workarea 3.3.8
excerpt: Patch release notes for Workarea 3.3.8.
---

# Workarea 3.3.8

Patch release notes for Workarea 3.3.8.

## Allow Changing Taxonomy Slugs in Workflow

Workarea now ensures that taxonomy changes occur outside the context of
a release, in order to address a validation error that occurs when an
admin attempts to add a new taxon in the middle of the taxonomy tree.

### Issues

- [ECOMMERCE-6184](https://jira.tools.weblinc.com/browse/ECOMMERCE-6184)

### Pull Requests

- [3561](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3561/overview)

### Commits

- [f60b9c2da50be377c0a3e25970444bb5358ae202](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/f60b9c2da50be377c0a3e25970444bb5358ae202)


## Correct Styling of Additional Navigation Sections in Admin 

This prevents issues like when the blog navigation section having 100%
width when installed by configuring the `flex-grow` and
`justify-content` [Flexbox](https://developer.mozilla.org/en-US/docs/Learn/CSS/CSS_layout/Flexbox) properties.

### Issues

- [ECOMMERCE-6330](https://jira.tools.weblinc.com/browse/ECOMMERCE-6330)

### Pull Requests

- [3580](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3580/overview)

### Commits

- [d5fb89882a7119c8df36699d6f24ff8f5ff14c6b](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/d5fb89882a7119c8df36699d6f24ff8f5ff14c6b)


## Allow Spaces in Product Filter Pattern Validation

Filters cannot have the "Type" property associated with them, so
Workarea has a browser-based pattern validation ensuring the filter name
is never "Type" or "type". This regular expression had the unintentional
effect of blocking spaces in new filter names through the admin, resulting
in some confusion. Add to the regex in order to allow it to support
spaces before or after the word "Type" is detected (or at all).

Solved by **Brian Berg**.


### Issues

- [ECOMMERCE-6163](https://jira.tools.weblinc.com/browse/ECOMMERCE-6163)

### Pull Requests

- [3563](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3563/overview)

### Commits

- [c2b760a5374e98845e31e59ddcbba21c01e5d4b7](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c2b760a5374e98845e31e59ddcbba21c01e5d4b7)


## Create New Items With Parent/Child Rows On CSV Imports

CSV Imports now have the ability to create new elements tied to a
client-provided arbitrary ID, which also forms the basis for identifiers
not originating from Workarea. Introduces a new type, `StringId`, which
falls back to a generated `BSON::ObjectId`, but can also accept an
arbitrary String (so long as it's unique) provided by the client as a
means of identifying multiple rows as the same parent object. New models
that can be imported/exported can use the following line in their model
definitions to take advantage of this:

```ruby
field :_id, type: StringId, default: -> { BSON::ObjectId.new }
```

### Issues

- [ECOMMERCE-6241](https://jira.tools.weblinc.com/browse/ECOMMERCE-6241)

### Pull Requests

- [3564](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3564/overview)

### Commits

- [c605ee8859e827193b311355748630f4eb6f2fe9](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/c605ee8859e827193b311355748630f4eb6f2fe9)


## Internationalize Price Range Facets Text

Add translations for the "Over" and "Under" text in price range facets,
named `workarea.facets.price_range.over` and
`workarea.facets.price_range.under`, respectively. This is the text that
appears in price range filters on the storefront.

### Issues

- [ECOMMERCE-6292](https://jira.tools.weblinc.com/browse/ECOMMERCE-6292)

### Pull Requests

- [3566](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3566/overview)

### Commits

- [5f32caf8029845af1e9dfba48ba8f944ca56554d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/5f32caf8029845af1e9dfba48ba8f944ca56554d)


## Audit Storefront for Accessibility

The aXe audit uncovered more issues related to accessibility in the bare
storefront user interface. Mostly related to improper ARIA grouping and
labels in the markup, these issues were resolved all at once, and so for
more information it's recommended you check out the commit and diff for
this particular issue.

### Issues

- [ECOMMERCE-6272](https://jira.tools.weblinc.com/browse/ECOMMERCE-6272)

### Pull Requests

- [3568](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3568/overview)

### Commits

- [15160e99cd55bc391fe43a6ccc24141808127114](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/15160e99cd55bc391fe43a6ccc24141808127114)


## Disable Request Throttling For Admins

Logged-in admin users are no longer bound by the `Rack::Attack` rules
for abusive clients. Add a safelist rule that checks whether the `:admin`
cookie is present and `true`. If so, the request is "safelisted",
meaning any other rule (like `blocklist` or `fail2ban`) is ignored. This
fixes issues stemming from multiple customer service representatives
using the admin from the same outbound IP address

### Issues

- [ECOMMERCE-6318](https://jira.tools.weblinc.com/browse/ECOMMERCE-6318)

### Pull Requests

- [3570](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3570/overview)

### Commits

- [efdf52dc150a896c5642293813122ef341a9b018](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/efdf52dc150a896c5642293813122ef341a9b018)


