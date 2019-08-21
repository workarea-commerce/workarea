---
title: Workarea 3.0.60
excerpt: Patch release notes for Workarea 3.0.60.
---

# Workarea 3.0.60

Patch release notes for Workarea 3.0.60.

## Fix New Release Form Creating Duplicates

The "with a new release" selection on the release selector pops up a
mini form which prompts the user for the name of their new release. This
form is dismissed if the user clicks the button, but still allows
potential user input (including multiple submits), causing duplicate
releases to be accidentally created if one hits enter _and_ clicks the
"Add" button before the page refreshes. Prevent this by adding
`data-disable-with` to the button so that it can't be submitted twice in
the same request cycle.

### Issues

- [ECOMMERCE-6837](https://jira.tools.weblinc.com/browse/ECOMMERCE-6837)

### Pull Requests

- [4052](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4052/overview)

## Fix Duplication in Search Suggestions Indexing

This is caused by not using the query ID as the ID for the suggestion in
its index after the new metrics engine in v3.4. Additionally, the
`BulkIndexSearches` job was no longer in the scheduler, it has been
re-added.

### Issues

- [ECOMMERCE-6927](https://jira.tools.weblinc.com/browse/ECOMMERCE-6927)

### Pull Requests

- [4049](https://stash.tools.weblinc.com/projects/WL/repos/workarea/pull-requests/4049/overview)

