---
title: Workarea 3.5.25
excerpt: Patch release notes for Workarea 3.5.25.
---

# Workarea 3.5.25

Patch release notes for Workarea 3.5.25.

## Allow admin config array fields to define a values type

This is useful when the values in an array need to be typecasted for the
functionality to work.

### Pull Requests

- [564](https://github.com/workarea-commerce/workarea/pull/564)

## Update releasable active test to work without localized active fields

### Pull Requests

- [563](https://github.com/workarea-commerce/workarea/pull/563)

## Check if a releasable has a localized active field before redefining it

If Workarea.config.localized_active_field is set to false, the active
field is redefined for each Releasable model to ensure the configuration
is honored. With inherited models like discounts, this can cause the
redefinition of active multiple times causing it to override custom active
behaviors for segments. Only redefining the method if its currently in
the models localized_fields list should ensure this does not happen.

### Pull Requests

- [563](https://github.com/workarea-commerce/workarea/pull/563)

## Update display of release changeset to handle large changesets

This fixes admin performance problems when dealing with releases with many
changesets. Uploading an import with a lot of updates is a common cause of this
problem.

### Pull Requests

- [562](https://github.com/workarea-commerce/workarea/pull/562)

## Use inline_svg fallback for missing releasable icons

This ensures the proper search indexes are in place when you switch
locales for an integration test.

### Pull Requests

- [568](https://github.com/workarea-commerce/workarea/pull/568)

## Simplify undo releases, allow multiple undo releases from a single release

This allows admins to build an undo release for an existing undo release. This
can be very helpful in situations where the changes desired can't be represented
under the previous undo setup, because the desired state can't be represented
as changes from the currently live state.

### Pull Requests

- [567](https://github.com/workarea-commerce/workarea/pull/567)

## Fix undo releases not causing models to reindex

Because the changeset is the only getting saved when building an undo,
admin reindexing for the affected models isn't happening. This change
triggers callbacks to ensure any related side-effects happen.

### Pull Requests

- [571](https://github.com/workarea-commerce/workarea/pull/571)

## Move release undo changeset building to Sidekiq for large changesets

For larger releases, building undos during the request causes timeouts.

### Pull Requests

- [574](https://github.com/workarea-commerce/workarea/pull/574)

## Index search customizations, handle missing search models for changeset releasables

This was for consistency in viewing upcoming releases through search results.

### Pull Requests

- [574](https://github.com/workarea-commerce/workarea/pull/574)

## Fix admin indexing for embedded model changes

When embedded models are changed, their root documents weren't being
reindexed for admin search. This ensures that indexing happens correctly.

### Pull Requests

- [574](https://github.com/workarea-commerce/workarea/pull/574)
