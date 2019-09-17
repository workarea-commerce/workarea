---
title: Workarea 3.3.34
excerpt: Patch release notes for Workarea 3.3.34.
---

# Workarea 3.3.34

Patch release notes for Workarea 3.3.34.

## Customize Search Queries That Return an Exact Match

It's currently possible to customize search queries that return an exact
match, but instead of seeing the customized results when you run the
query, you'll be redirected to the product page since the
`StorefrontSearch::ExactMatches` middleware stops further middleware
from running and sets a redirect to the product path. To resolve the issue,
Workarea will now ignore this middleware if a customization is present
on the search response.

Discovered by **Ryan Tulino** of **Syatt Media**. Thanks Ryan!

### Issues

- [ECOMMERCE-7063](https://jira.tools.weblinc.com/browse/ECOMMERCE-7063)

### Pull Requests

- [4177](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4177/overview)

