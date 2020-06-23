---
title: Workarea 3.5.14
excerpt: Patch release notes for Workarea 3.5.14.
---

# Workarea 3.5.14

Patch release notes for Workarea 3.5.14.

## Reset Geocoder between tests

This ensures individual tests monkeying around with Geocoder config will
get restored before the next test runs.

### Pull Requests

- [458](https://github.com/workarea-commerce/workarea/pull/458)

## Fix indexing categorization changesets for deleted releases

A category can have orphan changesets (from deleted releases) that cause
an error when indexing the percolation document for that category.

### Pull Requests

- [454](https://github.com/workarea-commerce/workarea/pull/454)

## Disable previewing for already published, unscheduled releases

Due to the previewing in the search index, previewing a published and
unscheduled release can cause issues that require it to go through
scheduling to get reindexed.

### Pull Requests

- [453](https://github.com/workarea-commerce/workarea/pull/453)

## Fix promo code counts in admin

Previously, promo codes could only be generated once through the admin,
so rendering the count of all promo codes as the count requested to be
generated was working out. However, as CSV imports and API updates became
more widespread, this began to break down as the `#count` field would
have to be updated each time a new set of promo codes were added.
Instead of reading from this pre-defined field on the code list, render
the actual count of promo codes from the database on the code list and
promo codes admin pages.

### Pull Requests

- [452](https://github.com/workarea-commerce/workarea/pull/452)

## Use display name for applied facet values

When rendering the applied filters, wrap the given facet value in
the `facet_value_display_name` helper, ensuring that the value rendered
is always human readable. This addresses an issue where if the applied
filter value is that of a BSON ID, referencing a model somewhere, the
BSON ID was rendered in place of the model's name.

### Pull Requests

- [451](https://github.com/workarea-commerce/workarea/pull/451)

## Fix index duplicates after a release is removed

When a release is deleted, its changes must be reindexed to fix previews
for releases scheduled after it. This manifests as duplicate products
when previewing releases.

### Pull Requests

- [450](https://github.com/workarea-commerce/workarea/pull/450)

## Fix segments workflow setup duplication

The setup form for the new custom segment workflow did not include the
ID of an existing segment (if persisted) in the form when submitted,
causing multiple duplicate segment records to be created when users go
back to the setup step in the workflow. None of the other steps are
affected because the ID appears in the URL, but the setup step does a
direct POST to `/admin/create_segments`, thus causing this problem.

### Pull Requests

- [448](https://github.com/workarea-commerce/workarea/pull/448)

## Update queue for release reschedule indexing

This should be in the releases queue, which has top priority. This will
help decrease the latency to accurate previews.

### Pull Requests

- [447](https://github.com/workarea-commerce/workarea/pull/447)

## Fix indexing after a release publishes

Due to potential changes in the index, publishing a release can result
in duplicate products when previewing.

### Pull Requests

- [447](https://github.com/workarea-commerce/workarea/pull/447)
