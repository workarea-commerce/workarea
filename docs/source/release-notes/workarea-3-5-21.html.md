---
title: Workarea 3.5.21
excerpt: Patch release notes for Workarea 3.5.21.
---

# Workarea 3.5.21

Patch release notes for Workarea 3.5.21.

## Try to clarify how to use search synonyms

There has been repeated confusion around why/how to use synonyms, so this is an
attempt to clarify.

### Pull Requests

- [529](https://github.com/workarea-commerce/workarea/pull/529)

## Prevent clearing out navigable when saving taxons

The `WORKAREA.newNavigationTaxons` module was looking in the wrong place
for the selected navigable item, therefore the `selected` var would
always return `undefined`, causing the `navigable_id` param to be
blank every time. Fix this by querying for the correct DOM node (the
`[data-new-navigation-taxon]` element) and pulling the selected ID from
its data.

### Pull Requests

- [539](https://github.com/workarea-commerce/workarea/pull/539)

## Fix skip services

This was broken due to the admin-based configuration looking for a Mongo
connections.

### Pull Requests

- [532](https://github.com/workarea-commerce/workarea/pull/532)

## Fix test that will never fail

This test for the `StatusReporter` worker asserted `2`, which will never
fail because `2` will never be falsy. Updated the assertion to use the
intended `assert_equals`.

### Pull Requests

- [536](https://github.com/workarea-commerce/workarea/pull/536)

## Refactor product entries to allow accessing logic per-product

This allows easier reuse of this logic, specifically for the site
builder plugin we're working on.

### Pull Requests

- [537](https://github.com/workarea-commerce/workarea/pull/537)

## Make CSV test more robust to decorations

Improve this test so decorating ApplicationDocument to add a field won't
cause the test to break.

### Pull Requests

- [538](https://github.com/workarea-commerce/workarea/pull/538)
