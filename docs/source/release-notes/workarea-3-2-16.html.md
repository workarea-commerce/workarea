---
title: Workarea 3.2.16
excerpt: Patch release notes for Workarea 3.2.16.
---

# Workarea 3.2.16

Patch release notes for Workarea 3.2.16.

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


## Remove Reverted Commits From Changelog

Commits that get reverted from the codebase should not be included in a
changelog, but the `workarea:changelog` Rake task shipped to plugins was
not properly omitting them. The task has been altered to match on the
subject rather than the body of the commit message, and the `CHANGELOG.md`
file has been manually updated to remove existing revert messages (as
well as the commits they're reverting).

### Issues

- [ECOMMERCE-6121](https://jira.tools.weblinc.com/browse/ECOMMERCE-6121)

### Pull Requests

- [3574](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/3574/overview)

### Commits

- [20bfbf0c0c8d15aeff1a986e8bdd89bec33afa2d](https://stash.tools.weblinc.com/projects/WL/repos/workarea/commits/20bfbf0c0c8d15aeff1a986e8bdd89bec33afa2d)


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


